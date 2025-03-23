import json
import time
import sys
import argparse
from urllib.request import urlopen
from typing import Dict


BYPASS_OUTBOUND_TYPE = ["direct", "block", "ssh", "selector", "dns"]


def parse_arg():
    parser = argparse.ArgumentParser()
    parser.add_argument("-t", "--template")
    parser.add_argument("-u", "--url")
    parser.add_argument("-o", "--output")

    return parser.parse_args(sys.argv[1:])


def render(template: Dict, url: str, output: str):
    retry_count = 3

    config = None
    err = None
    for i in range(retry_count):
        try:
            config = json.loads(urlopen(url).read())
            break
        except Exception as e:
            err = e
            time.sleep(3)

    if config is None:
        raise err

    for outbound in template["outbounds"]:
        if outbound["tag"] == "select":
            selector = outbound

    default_candidate = None
    for outbound in config["outbounds"]:
        if outbound["type"] not in BYPASS_OUTBOUND_TYPE:
            if "outbounds" not in selector:
                selector["outbounds"] = []

            template["outbounds"].append(outbound)
            selector["outbounds"].append(outbound["tag"])

            if (
                "当前流量" not in outbound["tag"]
                and "到期时间" not in outbound["tag"]
                and not default_candidate
            ):
                default_candidate = outbound["tag"]
                print(default_candidate)

    if "default" not in selector and default_candidate:
        selector["default"] = default_candidate

    with open(output, "w") as f:
        f.write(json.dumps(template, ensure_ascii=False))


args = parse_arg()
with open(args.template, "r") as f:
    s = f.read()
    render(json.loads(s), args.url, args.output)
