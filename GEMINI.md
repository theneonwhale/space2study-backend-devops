## Project Overview

This project, Space2Study-BackEnd-mvp, is the backend for a platform that connects experts and learners. It appears to be a Node.js application using Express.js and MongoDB. The project is well-structured with a clear separation of concerns and includes DevOps practices like Infrastructure as Code (Terraform), configuration management (Ansible), and containerization (Docker).

## Tech Stack

- **Backend:** Node.js, Express.js
- **Database:** MongoDB with Mongoose
- **Authentication:** JSON Web Tokens (JWT)
- **Testing:** Jest, Supertest
- **Linting & Formatting:** ESLint, Prettier
- **API Documentation:** Swagger (OpenAPI)
- **DevOps:**
    - **Containerization:** Docker
    - **Infrastructure as Code:** Terraform
    - **Configuration Management:** Ansible
    - **CI/CD:** Husky for pre-commit hooks
- **File Storage:** Azure Storage
- **Email:** Nodemailer

## Project Structure

The project follows a standard Node.js application structure:

- `src/`: Contains the main application source code.
    - `controllers/`: Handles incoming requests and sends responses.
    - `services/`: Contains the business logic of the application.
    - `models/`: Defines the Mongoose schemas and models.
    - `routes/`: Defines the API endpoints.
    - `middlewares/`: Custom middleware for handling requests.
    - `validation/`: validation schemas.
    - `utils/`: Utility functions.
- `docs/`: Contains API documentation in YAML format.
- `ansible/`: Ansible playbooks for server configuration.
- `terraform/`: Terraform files for managing infrastructure.
- `devops/`: Contains docker-compose and vault configuration.

## Key Scripts

- `npm run start`: Starts the development server with `nodemon`.
- `npm run start:prod`: Starts the application in production mode.
- `npm test`: Runs the test suite using Jest.
- `npm run lint`: Lints the codebase using ESLint.

## Coding Style

- The project uses ESLint and Prettier to enforce a consistent coding style.
- It follows a layered architecture, separating concerns into controllers, services, and models.
- Imports seem to use module aliases, for instance, ` '@/constants' `.

## How to work with this project

### Running Tests

To run the test suite, use the following command:

```bash
npm test
```

### Adding a new feature

To add a new feature, follow these steps:

1.  Create a new branch for the feature: `git checkout -b feature/your-feature-name`
2.  Create new files or modify existing ones in the `src/` directory, following the existing project structure and coding style.
3.  Add new routes in the `src/routes/` directory and implement the corresponding controller and service logic.
4.  Add unit tests for the new feature in the `src/test/` directory.
5.  Update the API documentation in the `docs/` directory if necessary.
6.  Run `npm test` to ensure all tests pass.
7.  Commit your changes and open a pull request.
