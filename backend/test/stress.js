import http from 'k6/http';
import { sleep, check } from 'backend/test/stress';
import { Counter } from 'k6/metrics';

// A simple counter for http requests

export const requests = new Counter('http_reqs');
const requestsGo = new Counter('http_reqs_go');

// you can specify stages of your test (ramp up/down patterns) through the options object
// target is the number of VUs you are aiming for

export const options = {
    discardResponseBodies: true,
    scenarios: {
        contacts: {
            executor: 'ramping-vus',
            startVUs: 50,
            stages: [
                { duration: '2m', target: 100 },
                { duration: '2m', target: 200 },
            ],
            gracefulRampDown: '1m',
        },
    },
    thresholds: {
        http_reqs: ['count <= 20000000'],
    },
};

export default function () {
    // our HTTP request, note that we are saving the response to res, which can be accessed later

    const res = http.get('http://server.movies.co/movies/');

    sleep(0.1);

    const checkRes = check(res, {
        'status is 200': (r) => r.status === 200,
    });
}