import sys
import json
from string import Template

obj = json.load(sys.stdin)
text_array = []
if 'results' in obj:
    if len(obj['results']):
        # only get the first one for now
        for item in obj['results'][:1]:
            for n in item['formatted']:
                if n['type'] == 'text':
                    reply = f"{n['text']}\n"
                if n['type'] == 'rdl':
                    reply += f"A: rdl: {n['callback']}\n"
            text_array.append(reply)
        print("".join(text_array))
    else:
        print("Sorry, no match was found.")
elif 'error' in obj:
    print(f"[Error] {obj['error']}")
else:
    print(f"[Error] {obj}")