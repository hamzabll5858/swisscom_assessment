package utils

import (
	"encoding/json"
	"github.com/prometheus/client_golang/prometheus"
	"io/ioutil"
	"net/http"
)

var HttpRequestsTotal = prometheus.NewCounter(
	prometheus.CounterOpts{
		Name:        "movies_http_requests_total",
		Help:        "Total number of HTTP requests",
		ConstLabels: prometheus.Labels{"server": "api"},
	},
)

func ParseBody(r *http.Request, X interface{}) {
	if body, err := ioutil.ReadAll(r.Body); err == nil {
		if err := json.Unmarshal([]byte(body), X); err != nil {
			return
		}
	}
}
