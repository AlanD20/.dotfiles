# Container Setups

A few simple docker-compose files to setup containers locally.

## Common Commands

- Build Containers

  ```bash
  docker-compose up             # Every service
  docker-compose up -d redis # Only specified services
  ```

- Destroy Containers

  ```bash
  docker-compose down      # Every service
  docker-compose down cass # Only specified services
  ```

