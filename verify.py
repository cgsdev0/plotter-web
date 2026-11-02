#!/usr/bin/env python3

import sys

import jwt
from jwt import PyJWKClient


def verify(token):
    jwks_client = PyJWKClient("https://recurse.id/oauth/certs")
    signing_key = jwks_client.get_signing_key_from_jwt(token)
    jwt.decode(
        token,
        key=signing_key,
        audience="https://plot.recurse.com",
        options={"require": ["exp"]},
        algorithms=["ES256"],
    )


token = sys.stdin.readline().rstrip("\n")
verify(token)
