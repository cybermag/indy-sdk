from tests.utils import storage
from indy import ledger

import json
import pytest
import logging

logging.basicConfig(level=logging.DEBUG)


@pytest.fixture(autouse=True)
def before_after_each():
    storage.cleanup()
    yield
    storage.cleanup()


@pytest.mark.asyncio
async def test_build_get_claim_def_request_works():
    identifier = "identifier"
    _ref = 1
    signature_type = "signature_type"
    origin = "origin"

    expected_response = {
        "identifier": "identifier",
        "operation": {
            "type": "108",
            "ref": 1,
            "signature_type": "signature_type",
            "origin": "origin"
        }
    }

    response = json.loads((await ledger.build_get_claim_def_txn(
        identifier, _ref, signature_type, origin
    )).decode())
    assert expected_response.items() <= response.items()


@pytest.mark.asyncio
async def test_build_claim_def_request_works_for_correct_data_json():
    identifier = "identifier"
    signature_type = "CL"
    schema_seq_no = 1
    data = {
        "primary": {
            "n": "1",
            "s": "2",
            "rms": "3",
            "r": {
                "name": "1"
            },
            "rctxt": "1",
            "z": "1"
        }
    }

    expected_response = {
        "identifier": "identifier",
        "operation": {
            "ref": schema_seq_no,
            "data": json.dumps(data),
            "type": "102",
            "signature_type": signature_type
        }
    }

    response = json.loads((await ledger.build_claim_def_txn(
        identifier, schema_seq_no, signature_type, json.dumps(data)
    )).decode())
    assert expected_response.items() <= response.items()
