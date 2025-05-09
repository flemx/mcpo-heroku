#!/bin/bash

# Default values
API_KEY="top-secret"
CONFIG_FILE="mcp.json"
PORT=8000
FORCE_BUILD=false
CONTAINER_NAME="mcpo-server"
ENV_FILE=".env"  # Default .env file

# Help function
show_help() {
  echo "Usage: ./start.sh [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --api-key KEY       Set the API key (default: top-secret)"
  echo "  --config FILE       Specify config file (default: mcp.json)"
  echo "  --port PORT         Set the port number (default: 8000)"
  echo "  --name NAME         Set container name (default: mcpo-server)"
  echo "  --env-file FILE     Specify .env file path (default: .env)"
  echo "  --build             Force rebuild of Docker image even if it exists"
  echo "  --help              Show this help message"
  echo ""
  echo "Examples:"
  echo "  ./start.sh"
  echo "  ./start.sh --api-key \"my-secret\" --port 9000"
  echo "  ./start.sh --config custom.json --build"
  echo "  ./start.sh --name \"my-mcpo-instance\""
  echo "  ./start.sh --env-file .env.local"
  exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --api-key)
      API_KEY="$2"
      shift 2
      ;;
    --config)
      CONFIG_FILE="$2"
      shift 2
      ;;
    --port)
      PORT="$2"
      shift 2
      ;;
    --name)
      CONTAINER_NAME="$2"
      shift 2
      ;;
    --env-file)
      ENV_FILE="$2"
      shift 2
      ;;
    --build)
      FORCE_BUILD=true
      shift
      ;;
    --help)
      show_help
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# Check if env file exists
if [[ ! -f $ENV_FILE ]]; then
  echo "Warning: Environment file $ENV_FILE not found."
  echo "Some MCP servers might not work without required environment variables."
fi

# Check if image exists
if [[ "$(docker images -q my-mcpo 2> /dev/null)" == "" ]]; then
  echo "Docker image my-mcpo not found. Building..."
  docker build -t my-mcpo .
elif [[ "$FORCE_BUILD" == "true" ]]; then
  echo "Forcing rebuild of Docker image (--build option used)..."
  docker build -t my-mcpo .
else
  echo "Using existing my-mcpo Docker image (use --build to rebuild)"
fi

# Run the Docker container
echo "Starting mcpo server on port $PORT with config $CONFIG_FILE..."
docker run -p $PORT:8000 \
  --name "$CONTAINER_NAME" \
  -v "$(pwd)/$CONFIG_FILE:/app/$CONFIG_FILE" \
  -v "$(pwd)/custom:/app/custom" \
  -v "$(pwd)/$ENV_FILE:/app/$ENV_FILE" \
  --entrypoint mcpo \
  my-mcpo --api-key "$API_KEY" --config "/app/$CONFIG_FILE" --env-path "/app/$ENV_FILE"