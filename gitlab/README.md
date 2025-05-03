# GitLab for Code Keeper

This directory contains the configuration for running GitLab in Docker as part of the Code Keeper project.

## Getting Started

1. First, make sure Docker and Docker Compose are installed on your system.

2. The GitLab home environment variable is now automatically set using the `.env` file in this directory. You can modify it there if needed:

   ```bash
   # .env file contents
   GITLAB_HOME=/home/meelis/Projects/kj/code-keeper/gitlab
   ```

   This approach eliminates the need to manually export the variable before running docker-compose.

3. Start GitLab:

   ```bash
   cd code-keeper/gitlab
   docker compose up -d
   ```

4. Wait for GitLab to start (this may take a few minutes). You can check the startup progress with:

   ```bash
   docker logs -f code-keeper-gitlab
   ```

5. Access GitLab at http://localhost:8080

6. On first login, you'll be asked to set a password for the `root` user.

## SSH Access

To use Git over SSH:

1. The SSH port for GitLab has been configured as 2222 to avoid conflicts.
2. Configure your Git SSH access using:
   ```
   ssh://git@localhost:2222/user/project.git
   ```

## Integration with Code Keeper

GitLab has been configured to use the same Docker network as your other Code Keeper services, allowing for seamless integration.
