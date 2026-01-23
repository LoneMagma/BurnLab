cat > ~/.bin/ask << 'ASKEOF'
#!/bin/bash
QUERY="$*"
[[ -z "$QUERY" ]] && { 
    echo "BurnLab Knowledge Assistant"
    echo "Usage: ask <your question>"
    echo ""
    echo "Available knowledge bases:"
    ls -1 ~/zims/*.zim 2>/dev/null | xargs -n1 basename | sed 's/.zim//'
    exit 1
}

echo "Searching offline knowledge bases..."

# Search all ZIMs and combine results
CONTEXT=$(kiwix-search -z ~/zims/*.zim "$QUERY" 2>/dev/null | head -n 10)

if [[ -z "$CONTEXT" ]]; then
    echo "No results found in offline docs. Asking AI without context..."
    CONTEXT="No specific documentation found."
fi

# Query AI with context
ollama run qwen2.5-coder:1.5b-instruct << EOF
You are an offline coding assistant with access to these knowledge bases:
- Wikipedia (general knowledge)
- Stack Overflow (programming Q&A)
- MDN Web Docs (HTML/CSS/JavaScript)
- DevDocs (API references)
- Arch Wiki (Linux/system administration)
- Python documentation

Relevant documentation search results:
$CONTEXT

Question: $QUERY

Provide a concise, practical answer. If the documentation contains the answer, reference it. If not, use your knowledge to help.
EOF
ASKEOF
