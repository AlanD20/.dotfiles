# Docker Database Setup

This is a simple project that helps you setup a simple `MySQL`, `phpMyAdmin`,
`Mailpit/Mailhog`, `Kafka`, `Redis` containers in a single docker compose file.
The project contains a `docker compose` file with a `package.json` to run the
docker compose commands easily.

## Scripts

- Build Containers

  ```bash
  yarn up             # Every service
  yarn up mysql redis # Only specified services
  ```

- Destroy Containers

  ```bash
  yarn down             # Every service
  yarn down mailpit phpmyadmin # Only specified services
  ```

- Start Exisitng Containers

  ```bash
  yarn start
  ```

- Stop Exisitng Containers

  ```bash
  yarn stop
  ```
