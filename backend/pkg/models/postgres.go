package models

import (
	"github.com/go-pg/pg/v10"
	"github.com/spf13/viper"
)

var db *pg.DB

func init() {
	db = pg.Connect(&pg.Options{
		Addr:     viper.GetString("database.url"),
		User:     viper.GetString("database.username"),
		Password: viper.GetString("database.password"),
		Database: viper.GetString("database.database"),
	})
	err := createSchema()
	if err != nil {
		panic(err)
	}
}
