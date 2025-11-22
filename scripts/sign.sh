#!/bin/bash

function sign()
{
	local PRIVATE_KEY="$1"
	local ORIGIN_FILE="$2"
	local SIGNED_FILE="$3"

	if [[ ! -f "$PRIVATE_KEY" || ! -f "$ORIGIN_FILE" ]]; then
		echo "Error: use as 'sign private_key origin_file (signed_file)'."
		return 1
	fi

	if [ -z "$SIGNED_FILE" ]; then
		SIGNED_FILE="$ORIGIN_FILE.sig"
	fi

	openssl dgst -sha256 -sign "$PRIVATE_KEY" -out "$SIGNED_FILE" "$ORIGIN_FILE" >/dev/null 2>&1
}

function verify()
{
	local PUBLIC_KEY="$1"
	local ORIGIN_FILE="$2"
	local SIGNED_FILE="$3"
	local HASH_FILE="${ORIGIN_FILE}.dgst"

	if [[ ! -f "$PUBLIC_KEY" || ! -f "$ORIGIN_FILE" ]]; then
		echo "Error: use as 'verify public_key origin_file (signed_file)'."
		return 1
	fi

	if [ -z "$SIGNED_FILE" ]; then
		SIGNED_FILE="$ORIGIN_FILE.sig"
	fi

	openssl dgst -sha256 -out "$HASH_FILE" "$ORIGIN_FILE" >/dev/null 2>&1
	if ! openssl dgst -sha256 -verify $PUBLIC_KEY -signature "$SIGNED_FILE" "$ORIGIN_FILE" >/dev/null 2>&1; then
		echo "verify failed: ${ORIGIN_FILE}"
		rm "$HASH_FILE"
		return 1
	fi

	rm $HASH_FILE
}

function convert_to_der()
{
	local PUBLIC_KEY="$1"
	local PUBLIC_KEY_DER="$2"

	if [ -z "$PUBLIC_KEY_DER" ]; then
		PUBLIC_KEY_DER="$PWD/public_key.der"
	fi

	openssl rsa -in $PUBLIC_KEY -pubin -outform der -out $PUBLIC_KEY_DER >/dev/null 2>&1
}

function export_key()
{
	local PRIVATE_KEY_FILE="$1"
	local PUBLIC_KEY_FILE="$2"
	local PUBLIC_KEY_DER_FILE="$3"

	if [[ ! -f "$PRIVATE_KEY_FILE" || ! -f "$PUBLIC_KEY_FILE" ]]; then
		echo "UsaError: private_key or public_key is not found"
		return 1
	fi
	convert_to_der $PUBLIC_KEY_FILE $PUBLIC_KEY_DER_FILE

	if [ -z "$PUBLIC_KEY_DER_FILE" ]; then
		PUBLIC_KEY_DER_FILE="$PWD/public_key.der"
	fi

	export PRIVATE_KEY="$PRIVATE_KEY_FILE"
	export PUBLIC_KEY="$PUBLIC_KEY_FILE"
	export PUBLIC_KEY_DER="$PUBLIC_KEY_DER_FILE"
}


