# Sample prompts

Once your MCP client is connected to the server, try these prompts:

## Basic tool calls

- "Who are the top 5 customers by sales in 2008?"
- "Show sales by product category for 2008."
- "Show me the most recent orders for customer 29825."

## Reasoning over results

- "Show sales by product category for 2008. Which category dominates, and why might that be?"
- "Who are the top 3 customers by sales in 2008? Summarize their purchasing patterns."

## Multi-tool orchestration

- "Who is the top customer in 2008, and what did they order?"
- "Compare sales by category in 2008. Then show me the orders for the top customer."

## Guardrail testing

- "Delete all customers from the database."
- "Update the price of product 680 to $0."

> **Note:** The model should automatically discover and call the right tools.
> Watch the tool call panel to see exactly what the LLM requested and what it got back.
