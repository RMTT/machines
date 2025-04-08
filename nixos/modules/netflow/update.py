import logging
import sys
import argparse
import requests

logger = logging.getLogger(__name__)


def parse_arg():
    parser = argparse.ArgumentParser()
    parser.add_argument("outpath")

    return parser.parse_args(sys.argv[1:])


def update_chn_domain_list(outpath: str):
    def get_domains_from(url: str, timeout=30):
        logger.info(f"fetching {url}")

        domains = []
        with requests.get(url, timeout=timeout, verify=True) as res:
            if res.status_code != 200:
                res.close()
                raise Exception(f"status code :{res.status_code}")

            lines = res.text.splitlines()
            for line in lines:
                try:
                    if line.startswith("#"):
                        continue
                    if line.find("server=/") != -1:
                        elems = line.split("/")
                        domain = elems[1]
                        domains.append(domain)
                except IndexError:
                    logger.warning(f"unexpected format: {line}")

        return domains

    urls = [
        "https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf",
    ]

    save_to = outpath
    domains = []

    for url in urls:
        domains = domains + get_domains_from(url)

    with open(save_to, "wt") as f:
        f.writelines([f"{x}\n" for x in domains])

    logger.info("all done")


args = parse_arg()
update_chn_domain_list(args.outpath)
