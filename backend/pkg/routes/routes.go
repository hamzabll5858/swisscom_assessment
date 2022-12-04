package routes

import (
	"github.com/gorilla/mux"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"movies-service/pkg/controllers"
)

var RegisterRecipeRoutes = func(router *mux.Router) {
	router.HandleFunc("/", controllers.GetHealth).Methods("GET")
	router.HandleFunc("/movies/", controllers.CreateMovie).Methods("POST")
	router.HandleFunc("/movies/", controllers.GetMovie).Methods("GET")
	router.HandleFunc("/healthz", controllers.GetHealth).Methods("GET")
	router.HandleFunc("/movies/{movieid}", controllers.GetMovieById).Methods("GET")
	router.HandleFunc("/movies/{movieid}", controllers.UpdateMovie).Methods("PUT")
	router.HandleFunc("/movies/{movieid}", controllers.DeleteMovie).Methods("DELETE")
	router.Handle("/metrics", promhttp.Handler())
}
