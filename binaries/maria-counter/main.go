package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"

	_ "github.com/go-sql-driver/mysql"
	"github.com/gorilla/mux"
)

var (
	databaseAddress  string
	databasePort     int
	databaseUser     string
	databasePassword string
	listenAddr       = ":8080"
)

func init() {
	databaseAddress = os.Getenv("DATABASE_ADDR")
	port, err := strconv.Atoi(os.Getenv("DATABASE_PORT"))
	if err == nil {
		databasePort = port
	}
	databaseUser = os.Getenv("DATABASE_USER")
	databasePassword = os.Getenv("DATABASE_PASSWORD")
}

func main() {
	db, err := sql.Open("mysql", fmt.Sprintf("%s:%s@tcp(%s:%d)/counters", databaseUser, databasePassword, databaseAddress, databasePort))
	if err != nil {
		log.Fatalf("error opening database connection: %v", err)
	}

	err = db.Ping()
	if err != nil {
		log.Fatalf("error pinging database: %v", err)
	}

	_, err = db.Exec("USE counters")
	if err != nil {
		log.Fatalf("Failed to use db: %v", err)
	}

	_, err = db.Exec(`
CREATE TABLE IF NOT EXISTS counters.counters (
  name text, count int
);
`)
	if err != nil {
		log.Fatalf("Failed to commit tx: %v", err)
	}

	r := mux.NewRouter()
	r.HandleFunc("/counter/{name}", NewGetCountHandler(db)).Methods("GET")
	r.HandleFunc("/counter/{name}", NewIncrementCountHandler(db)).Methods("POST")
	if err := http.ListenAndServe(listenAddr, r); err != nil {
		log.Fatalf("Server borked: %v", err)
	}
}

type QueryResult struct {
	Name  string
	Count int
}

func NewGetCountHandler(db *sql.DB) http.HandlerFunc {
	return func(resp http.ResponseWriter, req *http.Request) {
		v := mux.Vars(req)
		name := v["name"]
		rows, err := db.Query("SELECT count FROM counters WHERE name=?;", name)
		defer rows.Close()
		if err != nil {
			resp.WriteHeader(500)
			resp.Write([]byte(fmt.Sprintf("{\"err\": \"%s\"}", err.Error())))
			return
		}

		for rows.Next() {
			var result QueryResult
			err = rows.Scan(&result.Count)
			log.Printf("[ERR] Failed to scan: %v", err)
			resp.WriteHeader(200)
			resp.Write([]byte(fmt.Sprintf("{\"count\": \"%d\"}\n", result.Count)))
		}
		if err := rows.Err(); err != nil {
			resp.Write([]byte(fmt.Sprintf("{\"error\": \"%v\" }\n", err)))
		}
	}
}

func NewIncrementCountHandler(db *sql.DB) http.HandlerFunc {
	return func(resp http.ResponseWriter, req *http.Request) {
		v := mux.Vars(req)
		name := v["name"]
		_, err := db.Exec(`
		UPDATE counters
		SET count = count + 1
		WHERE name=?;`,
			name)

		if err != nil {
			resp.WriteHeader(500)
			r, err := json.Marshal(struct{ Error string }{Error: err.Error()})
			if err == nil {
				resp.Write(r)
			}
		}

		resp.WriteHeader(200)
		resp.Write([]byte("{}\n"))
	}
}
