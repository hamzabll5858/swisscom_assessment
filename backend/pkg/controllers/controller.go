package controllers

import (
	"encoding/json"
	"fmt"
	"github.com/gorilla/mux"
	"movies-service/pkg/models"
	"movies-service/pkg/utils"
	"net/http"
	"strconv"
)

func GetHealth(w http.ResponseWriter, r *http.Request) {
	// Custom metrics Prometheus
	utils.HttpRequestsTotal.Inc()

	health := &models.Health{
		Status: "OK",
	}
	res, _ := json.Marshal(health)
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write(res)
}

func GetMovie(w http.ResponseWriter, r *http.Request) {
	// Custom metrics Prometheus
	utils.HttpRequestsTotal.Inc()

	NewMovies, err := models.GetAllMovie()
	if err != nil {
		res, _ := json.Marshal(err.Error())
		w.WriteHeader(http.StatusBadRequest)
		w.Write(res)
	} else {
		res, _ := json.Marshal(NewMovies)
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write(res)
	}
}

func GetMovieById(w http.ResponseWriter, r *http.Request) {
	// Custom metrics Prometheus
	utils.HttpRequestsTotal.Inc()

	vars := mux.Vars(r)
	movieId := vars["movieid"]
	ID, err := strconv.ParseInt(movieId, 0, 0)
	if err != nil {
		fmt.Println("error while parsing")
	}
	movieDetails, err := models.GetMovieById(ID)
	if err != nil {
		res, _ := json.Marshal(err.Error())
		w.WriteHeader(http.StatusBadRequest)
		w.Write(res)
	} else {
		res, _ := json.Marshal(movieDetails)
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write(res)
	}
}

func CreateMovie(w http.ResponseWriter, r *http.Request) {
	// Custom metrics Prometheus
	utils.HttpRequestsTotal.Inc()

	createMovie := &models.Movie{}
	utils.ParseBody(r, createMovie)
	movie, err := models.CreateMovie(createMovie)
	if err != nil {
		res, _ := json.Marshal(err.Error())
		w.WriteHeader(http.StatusBadRequest)
		w.Write(res)
	} else {
		res, _ := json.Marshal(movie)
		w.WriteHeader(http.StatusOK)
		w.Write(res)
	}
}

func DeleteMovie(w http.ResponseWriter, r *http.Request) {
	// Custom metrics Prometheus
	utils.HttpRequestsTotal.Inc()

	vars := mux.Vars(r)
	movieId := vars["movieid"]
	ID, err := strconv.ParseInt(movieId, 0, 0)
	if err != nil {
		fmt.Println("error while parsing")
	}
	movie, err := models.DeleteMovie(ID)
	if err != nil {
		res, _ := json.Marshal(err.Error())
		w.WriteHeader(http.StatusBadRequest)
		w.Write(res)
	} else {
		res, _ := json.Marshal(movie)
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write(res)
	}
}

func UpdateMovie(w http.ResponseWriter, r *http.Request) {
	// Custom metrics Prometheus
	utils.HttpRequestsTotal.Inc()

	var updateMovie = &models.Movie{}
	utils.ParseBody(r, updateMovie)
	vars := mux.Vars(r)
	movieId := vars["movieid"]
	ID, err := strconv.ParseInt(movieId, 0, 0)
	if err != nil {
		fmt.Println("error while parsing")
	}
	updateMovie.ID = ID
	movieDetails, err := models.UpdateMovie(updateMovie)
	if err != nil {
		res, _ := json.Marshal(err.Error())
		w.WriteHeader(http.StatusBadRequest)
		w.Write(res)
	} else {
		res, _ := json.Marshal(movieDetails)
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write(res)
	}
}
