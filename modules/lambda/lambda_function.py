def handler(event, context):
    import json

    user_id = event['headers'].get('user-id', 'guest-user')
    query = event.get('queryStringParameters') or {}

    if 'date' in query:
        return {
            "statusCode": 200,
            "body": json.dumps({
                "user": user_id,
                "date": query['date'],
                "expenses": [
                    {"amount": 100, "category": "Food"},
                    {"amount": 200, "category": "Transport"}
                ]
            })
        }
    elif 'month' in query:
        return {
            "statusCode": 200,
            "body": json.dumps({
                "user": user_id,
                "month": query['month'],
                "summary": {
                    "Food": 500,
                    "Transport": 300
                }
            })
        }
    else:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Missing date or month query param"})
        }