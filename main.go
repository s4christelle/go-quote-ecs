package main

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/gocolly/colly"
)

// Quote represents a single quote with its details
type Quote struct {
	Text   string   ⁠ json:"quote" ⁠
	Author string   ⁠ json:"author" ⁠
	Tags   []string ⁠ json:"tags" ⁠
}

// ScrapeQuotes scrapes quotes from the website
func ScrapeQuotes() []Quote {
	quotes := []Quote{}

	// Create a new Colly collector
	c := colly.NewCollector()

	// Define what to do for each quote
	c.OnHTML(".quote", func(e *colly.HTMLElement) {
		text := e.ChildText(".text")
		author := e.ChildText(".author")
		tags := e.ChildAttrs(".tags a.tag", "href")

		quotes = append(quotes, Quote{
			Text:   text,
			Author: author,
			Tags:   tags,
		})
	})

	// Visit the website
	err := c.Visit("https://quotes.toscrape.com")
	if err != nil {
		log.Fatalf("Failed to scrape: %v", err)
	}

	return quotes
}

// HandleQuotes is the HTTP handler to return quotes as JSON
func HandleQuotes(w http.ResponseWriter, r *http.Request) {
	// Scrape the quotes
	quotes := ScrapeQuotes()

	// Limit to 100 quotes
	if len(quotes) > 100 {
		quotes = quotes[:100]
	}

	// Convert to JSON
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(quotes)
}

// main function starts the web server
func main() {
	http.HandleFunc("/quotes", HandleQuotes)

	log.Println("Server is running on http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}