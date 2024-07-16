#!/usr/bin/env bash

source "$FABLO_NETWORK_ROOT/fabric-docker/scripts/channel-query-functions.sh"

set -eu

channelQuery() {
  echo "-> Channel query: " + "$@"

  if [ "$#" -eq 1 ]; then
    printChannelsHelp

  elif [ "$1" = "list" ] && [ "$2" = "dinas" ] && [ "$3" = "peer0" ]; then

    peerChannelListTls "cli.dinas.palmmapping.co.id" "peer0.dinas.palmmapping.co.id:7041" "crypto-orderer/tlsca.orderer.palmmapping.co.id-cert.pem"

  elif
    [ "$1" = "list" ] && [ "$2" = "dinas" ] && [ "$3" = "peer1" ]
  then

    peerChannelListTls "cli.dinas.palmmapping.co.id" "peer1.dinas.palmmapping.co.id:7042" "crypto-orderer/tlsca.orderer.palmmapping.co.id-cert.pem"

  elif

    [ "$1" = "getinfo" ] && [ "$2" = "pemetaan-hutan-channel" ] && [ "$3" = "dinas" ] && [ "$4" = "peer0" ]
  then

    peerChannelGetInfoTls "pemetaan-hutan-channel" "cli.dinas.palmmapping.co.id" "peer0.dinas.palmmapping.co.id:7041" "crypto-orderer/tlsca.orderer.palmmapping.co.id-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$2" = "config" ] && [ "$3" = "pemetaan-hutan-channel" ] && [ "$4" = "dinas" ] && [ "$5" = "peer0" ]; then
    TARGET_FILE=${6:-"$channel-config.json"}

    peerChannelFetchConfigTls "pemetaan-hutan-channel" "cli.dinas.palmmapping.co.id" "$TARGET_FILE" "peer0.dinas.palmmapping.co.id:7041" "crypto-orderer/tlsca.orderer.palmmapping.co.id-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$3" = "pemetaan-hutan-channel" ] && [ "$4" = "dinas" ] && [ "$5" = "peer0" ]; then
    BLOCK_NAME=$2
    TARGET_FILE=${6:-"$BLOCK_NAME.block"}

    peerChannelFetchBlockTls "pemetaan-hutan-channel" "cli.dinas.palmmapping.co.id" "${BLOCK_NAME}" "peer0.dinas.palmmapping.co.id:7041" "crypto-orderer/tlsca.orderer.palmmapping.co.id-cert.pem" "$TARGET_FILE"

  elif
    [ "$1" = "getinfo" ] && [ "$2" = "pemetaan-hutan-channel" ] && [ "$3" = "dinas" ] && [ "$4" = "peer1" ]
  then

    peerChannelGetInfoTls "pemetaan-hutan-channel" "cli.dinas.palmmapping.co.id" "peer1.dinas.palmmapping.co.id:7042" "crypto-orderer/tlsca.orderer.palmmapping.co.id-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$2" = "config" ] && [ "$3" = "pemetaan-hutan-channel" ] && [ "$4" = "dinas" ] && [ "$5" = "peer1" ]; then
    TARGET_FILE=${6:-"$channel-config.json"}

    peerChannelFetchConfigTls "pemetaan-hutan-channel" "cli.dinas.palmmapping.co.id" "$TARGET_FILE" "peer1.dinas.palmmapping.co.id:7042" "crypto-orderer/tlsca.orderer.palmmapping.co.id-cert.pem"

  elif [ "$1" = "fetch" ] && [ "$3" = "pemetaan-hutan-channel" ] && [ "$4" = "dinas" ] && [ "$5" = "peer1" ]; then
    BLOCK_NAME=$2
    TARGET_FILE=${6:-"$BLOCK_NAME.block"}

    peerChannelFetchBlockTls "pemetaan-hutan-channel" "cli.dinas.palmmapping.co.id" "${BLOCK_NAME}" "peer1.dinas.palmmapping.co.id:7042" "crypto-orderer/tlsca.orderer.palmmapping.co.id-cert.pem" "$TARGET_FILE"

  else

    echo "$@"
    echo "$1, $2, $3, $4, $5, $6, $7, $#"
    printChannelsHelp
  fi

}

printChannelsHelp() {
  echo "Channel management commands:"
  echo ""

  echo "fablo channel list dinas peer0"
  echo -e "\t List channels on 'peer0' of 'Dinas'".
  echo ""

  echo "fablo channel list dinas peer1"
  echo -e "\t List channels on 'peer1' of 'Dinas'".
  echo ""

  echo "fablo channel getinfo pemetaan-hutan-channel dinas peer0"
  echo -e "\t Get channel info on 'peer0' of 'Dinas'".
  echo ""
  echo "fablo channel fetch config pemetaan-hutan-channel dinas peer0 [file-name.json]"
  echo -e "\t Download latest config block and save it. Uses first peer 'peer0' of 'Dinas'".
  echo ""
  echo "fablo channel fetch <newest|oldest|block-number> pemetaan-hutan-channel dinas peer0 [file name]"
  echo -e "\t Fetch a block with given number and save it. Uses first peer 'peer0' of 'Dinas'".
  echo ""

  echo "fablo channel getinfo pemetaan-hutan-channel dinas peer1"
  echo -e "\t Get channel info on 'peer1' of 'Dinas'".
  echo ""
  echo "fablo channel fetch config pemetaan-hutan-channel dinas peer1 [file-name.json]"
  echo -e "\t Download latest config block and save it. Uses first peer 'peer1' of 'Dinas'".
  echo ""
  echo "fablo channel fetch <newest|oldest|block-number> pemetaan-hutan-channel dinas peer1 [file name]"
  echo -e "\t Fetch a block with given number and save it. Uses first peer 'peer1' of 'Dinas'".
  echo ""

}
