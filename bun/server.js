import postgres from 'postgres';

const sql = postgres('postgres://postgres:postgres@127.0.0.1:5432/postgres');
let feedCache = null;
let cacheTime = 0;

Bun.serve({
  port: 3000,
  async fetch(req) {
    const url = new URL(req.url);
    const method = req.method;
    const authHeader = req.headers.get('authorization') || '';
    const userId = parseInt(authHeader.replace('Bearer ', ''), 10) || 1;

    if (method === 'GET' && url.pathname === '/feed') {
      const now = Date.now();
      if (feedCache && now - cacheTime < 1000) {
        return new Response(
            feedCache, {headers: {'Content-Type': 'application/json'}});
      }

      const posts = await sql`
        SELECT p.id, p.content, p.created_at, u.name as author,
          (SELECT count(*) FROM likes l WHERE l.post_id = p.id) as like_count
        FROM posts p
        JOIN users u ON p.user_id = u.id
        ORDER BY p.created_at DESC
        LIMIT 50
      `;

      feedCache = JSON.stringify(posts);
      cacheTime = now;
      return new Response(
          feedCache, {headers: {'Content-Type': 'application/json'}});
    }

    if (method === 'GET' && url.pathname.startsWith('/posts/')) {
      const postId = url.pathname.split('/')[2];
      const post = await sql`
        SELECT p.id, p.content, p.created_at, u.name as author,
          (SELECT count(*) FROM likes l WHERE l.post_id = p.id) as like_count
        FROM posts p
        JOIN users u ON p.user_id = u.id
        WHERE p.id = ${postId}
      `;
      return new Response(
          JSON.stringify(post[0] || {}),
          {headers: {'Content-Type': 'application/json'}});
    }

    if (method === 'POST' && url.pathname.match(/^\/posts\/\d+\/like$/)) {
      const postId = url.pathname.split('/')[2];
      await sql`
        INSERT INTO likes (user_id, post_id)
        VALUES (${userId}, ${postId})
        ON CONFLICT DO NOTHING
      `;
      return new Response(JSON.stringify({success: true}));
    }

    if (method === 'POST' && url.pathname === '/posts') {
      const body = await req.json();
      const newPost = await sql`
        INSERT INTO posts (user_id, content)
        VALUES (${userId}, ${body.content})
        RETURNING id
      `;
      return new Response(
          JSON.stringify(newPost[0]),
          {headers: {'Content-Type': 'application/json'}});
    }

    return new Response('Not Found', {status: 404});
  }
});