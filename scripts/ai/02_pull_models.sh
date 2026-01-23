#!/bin/bash
source "$(dirname "$0")/../common.sh"

MODEL="qwen2.5-coder:1.5b-instruct"

log "Pulling AI model: $MODEL (this may take 5-10 min)..."
ollama pull "$MODEL"

# Test model
log "Testing model..."
echo "print('Hello from BurnLab')" | ollama run "$MODEL" --verbose 2>&1 | head -n 5

log "Model ready: $MODEL"
