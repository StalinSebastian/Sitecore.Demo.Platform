# escape=`

#
# Development-only image for running Next.js in a containerized environment.
# Assumes that the Next.js rendering host source is mounted to c:\app.
#

ARG PARENT_IMAGE
FROM ${PARENT_IMAGE} AS debug

#Increase Javascript Heap size
#ENV NODE_OPTIONS="--max-old-space-size=8192"

# Create app directory
WORKDIR /app

# Expose ports
EXPOSE 3003
# EXPOSE 9229

# Start the Next.js application with Chrome debugging
ENTRYPOINT ["cmd", "/c", "npm install && npm run start:debug"]
