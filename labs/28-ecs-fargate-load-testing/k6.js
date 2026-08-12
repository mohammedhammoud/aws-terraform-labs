import http from "k6/http";
import { sleep } from "k6";

export const options = {
  stages: [
    { duration: "2m", target: 10 },
    { duration: "3m", target: 20 },
    { duration: "3m", target: 25 },
    { duration: "2m", target: 0 },
  ],
};

export default function () {
  http.get(`${__ENV.BASE_URL}/work`);
  sleep(0.1);
}