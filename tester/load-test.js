import {sleep} from 'k6';
import http from 'k6/http';

export const options = {
  thresholds: {
    http_req_duration: ['p(95)<500', 'p(99)<1000'],
    http_req_failed: ['rate<0.01'],
  },
};

export default function() {
  const baseUrl = __ENV.API_URL || 'http://127.0.0.1:3000';
  const userId = Math.floor(Math.random() * 50000) + 1;
  const params = {headers: {'Authorization': `Bearer ${userId}`}};

  http.get(`${baseUrl}/feed`, params);
  sleep(Math.random() * 4 + 3);

  const postId = Math.floor(Math.random() * 500000) + 1;
  http.get(`${baseUrl}/posts/${postId}`, params);
  sleep(Math.random() * 5 + 3);

  const rand = Math.random();
  if (rand < 0.15) {
    http.post(`${baseUrl}/posts/${postId}/like`, null, params);
  }
  if (rand >= 0.15 && rand < 0.17) {
    const payload = JSON.stringify({content: 'Load test post'});
    const postParams = {
      headers: {
        'Authorization': `Bearer ${userId}`,
        'Content-Type': 'application/json'
      }
    };
    http.post(`${baseUrl}/posts`, payload, postParams);
  }

  sleep(Math.random() * 10 + 5);
}