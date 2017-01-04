module Tests exposing (..)

import Test exposing (..)
import LoginSpec


all : Test
all =
    describe "Chat client test suite"
        [LoginSpec.all]

