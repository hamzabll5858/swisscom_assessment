package models

import (
	"github.com/go-pg/pg/v10/orm"
	"log"
)

type Health struct {
	Status string `json:"status"`
}

type Movie struct {
	ID     int64  `json:"id"`
	Name   string `json:"name"`
	Genre  string `json:"genre"`
	Rating int    `json:"rating"`
}

func createSchema() error {
	models := []interface{}{
		(*Movie)(nil),
	}
	for _, model := range models {
		err := db.Model(model).CreateTable(&orm.CreateTableOptions{
			IfNotExists: true,
		})
		if err != nil {
			return err
		}
	}
	return nil
}

func CreateMovie(movie *Movie) (*Movie, error) {
	_, err := db.Model(movie).Insert()
	if err != nil {
		log.Print(err)
	}
	return movie, err
}

func UpdateMovie(movie *Movie) (*Movie, error) {
	_, err := db.Model(movie).WherePK().Update()
	if err != nil {
		log.Print(err)
	}
	return movie, err
}

func GetAllMovie() ([]Movie, error) {
	var Movies []Movie
	err := db.Model(&Movies).Select()
	if err != nil {
		log.Print(err)
	}
	return Movies, err
}

func GetMovieById(Id int64) (Movie, error) {
	var getMovie Movie
	err := db.Model(&getMovie).Where("id = ?", Id).Select()
	if err != nil {
		log.Print(err)
	}
	return getMovie, err
}

func DeleteMovie(Id int64) (Movie, error) {
	var movie Movie
	_, err := db.Model(&movie).Where("id = ?", Id).Delete()
	if err != nil {
		log.Print(err)
	}
	return movie, err
}
