# Go Quotes App on AWS ECS (Fargate)

A Go web application that scrapes quotes from `quotes.toscrape.com` and returns up to 100 results as JSON via an HTTP endpoint. This repository includes instructions for local development, containerization with Docker, and deployment to AWS ECS (Fargate) using Terraform.

## Table of Contents
- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Local Development](#local-development)
- [Containerization with Docker](#containerization-with-docker)
- [AWS Deployment with Terraform & ECS](#aws-deployment-with-terraform--ecs)
  1. [Initialize & Apply Terraform](#1-initialize--apply-terraform)
  2. [Push Docker Image to ECR](#2-push-docker-image-to-ecr)
  3. [ECS Service Deployment & Update](#3-ecs-service-deployment--update)
  4. [Verification](#4-verification)
- [Cleanup](#cleanup)
- [Additional Notes](#additional-notes)

## 1. Overview
- **Language:** Go
- **Web Scraper:** Uses the Colly library
- **Endpoint:** Returns JSON quotes at `GET /quotes`
- **Deployment:**
  - Docker for containerization
  - AWS ECS (Fargate) for serverless containers
  - Application Load Balancer (ALB) for traffic distribution
  - Auto Scaling based on CPU usage
  - Terraform for Infrastructure as Code

## 2. Architecture
```
        ┌───────────────┐       (1) 
        │    AWS ECR    │  <-- Docker image
        └───────────────┘
               │
               ▼
        ┌────────────────┐   (2)
        │   AWS ECS      │  <-- Fargate tasks run Go app
        └────────────────┘
               │
               ▼
        ┌────────────────┐   (3)
        │ ALB (HTTP:80)  │  <-- Routes traffic to ECS tasks
        └────────────────┘
               │
               ▼
     User Traffic (Internet)
```
- **AWS ECR:** Hosts the Docker image.
- **AWS ECS (Fargate):** Runs containers in a serverless environment.
- **Application Load Balancer (ALB):** Routes incoming requests to running containers in ECS.

## 3. Prerequisites
- **Go (1.18+ recommended):** [Install Go](https://golang.org/dl/)
- **Docker:** [Install Docker](https://www.docker.com/)
- **AWS CLI (with valid credentials):** [Install AWS CLI](https://aws.amazon.com/cli/)
- **Terraform (1.1+):** [Install Terraform](https://www.terraform.io/)
- **Git:** [Install Git](https://git-scm.com/)

## 4. Local Development

### Clone the Repository
```bash
git clone <repository-url>
cd go-quotes-ecs-deployment
```

### Initialize Go Module & Install Dependencies
```bash
go mod init go-scraper
go get -u github.com/gocolly/colly
go mod tidy
```

### Create/Update `main.go`
```go
package main

import (
    "encoding/json"
    "log"
    "net/http"

    "github.com/gocolly/colly"
)

type Quote struct {
    Text   string   `json:"quote"`
    Author string   `json:"author"`
    Tags   []string `json:"tags"`
}

func ScrapeQuotes() []Quote {
    quotes := []Quote{}
    c := colly.NewCollector()

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

    if err := c.Visit("https://quotes.toscrape.com"); err != nil {
        log.Fatalf("Failed to scrape: %v", err)
    }
    return quotes
}

func HandleQuotes(w http.ResponseWriter, r *http.Request) {
    quotes := ScrapeQuotes()
    if len(quotes) > 100 {
        quotes = quotes[:100]
    }
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(quotes)
}

func main() {
    http.HandleFunc("/quotes", HandleQuotes)
    log.Println("Server is running on http://localhost:8080")
    log.Fatal(http.ListenAndServe(":8080", nil))
}
```

### Run the App
```bash
go run main.go
```

### Test Locally
Visit: `http://localhost:8080/quotes` in your browser or use `curl`. You should see a JSON array of quotes.

## 5. Containerization with Docker

### Create a Dockerfile
```dockerfile
# Step 1: Build stage
FROM golang:1.23 AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o main .

# Step 2: Runtime stage
FROM scratch
COPY --from=builder /app/main .
EXPOSE 8080
CMD ["./main"]
```

### Build the Image
```bash
docker build -t go-quotes-app:latest .
```

### Run the Container
```bash
docker run -p 8080:8080 go-quotes-app:latest
```

### Verify
Go to: `http://localhost:8080/quotes` in your browser or use `curl`.

## 6. AWS Deployment with Terraform & ECS

### 1. Initialize & Apply Terraform
#### Terraform Init
```bash
terraform init
```
#### Terraform Plan
```bash
terraform plan
```
#### Terraform Apply
```bash
terraform apply
```
Type `yes` when prompted.

After successful creation, Terraform outputs important information (e.g., `repository_url`, `alb_dns_name`, etc.).

### 2. Push Docker Image to ECR
#### Authenticate Docker to ECR
```bash
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
```
#### Tag the Docker Image
```bash
docker tag go-quotes-app:latest 123456789012.dkr.ecr.us-east-1.amazonaws.com/go-quotes-app:latest
```
#### Push the Docker Image
```bash
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/go-quotes-app:latest
```

### 3. ECS Service Deployment & Update
- Option 1: If your task definition is already configured for `:latest`, re-run `terraform apply` or force a new deployment in ECS.
- Option 2: If you version your images, update the task definition to the new tag, then apply again.

### 4. Verification
#### Find Your ALB DNS Name
- From Terraform output (e.g., `alb_dns_name`), or
- AWS Console under EC2 -> Load Balancers

#### Check the `/quotes` Endpoint
```bash
curl http://<ALB_DNS_NAME>/quotes
```
You should see the JSON quotes response.

## 7. Cleanup
- To clean up all resources, run:
```bash
terraform destroy
```
Type `yes` when prompted.

## 8. Additional Notes
- Ensure your AWS credentials have sufficient permissions for ECR, ECS, and ALB.
- Modify the `main.go` or `Dockerfile` as needed to fit specific project requirements.
- Use a CI/CD pipeline for automated deployment to AWS.
