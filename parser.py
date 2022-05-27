import sys
import json
from string import Template

obj = json.load(sys.stdin)
text_array = []
if 'results' in obj:
    if len(obj['results']):
        for item in obj['results']:
            for n in item['formatted']:
                if n['type'] == 'text':
                    reply = f"A: {n['text']}\n"
                if n['type'] == 'rdl':
                    reply += f"A: rdl: {n['callback']}\n"
            text_array.append(reply)
        print("".join(text_array))
    else:
        print("A: Sorry, no match was found.")
elif 'error' in obj:
    print(f"[Error] {obj['error']}")
else:
    print(f"[Error] {obj}")