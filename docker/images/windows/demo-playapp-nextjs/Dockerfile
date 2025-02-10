# escape=`

#
# Development-only image for running Next.js in a containerized environment.
# Assumes that the Next.js rendering host source is mounted to c:\app.
#

ARG PARENT_IMAGE
FROM ${PARENT_IMAGE} AS debug

# Create app directory
WORKDIR /app

# Expose the default Next.js port
EXPOSE 3000

# Start the Next.js application
ENTRYPOINT ["cmd", "/c", "npm install && npm run start:connected"]
#ENTRYPOINT "npm run start:connected --verbose"