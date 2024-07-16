#!/usr/bin/env bash

generateArtifacts() {
  printHeadline "Generating basic configs" "U1F913"

  printItalics "Generating crypto material for PalmMappingOrderer" "U1F512"
  certsGenerate "$FABLO_NETWORK_ROOT/fabric-config" "crypto-config-palmmappingorderer.yaml" "peerOrganizations/orderer.palmmapping.co.id" "$FABLO_NETWORK_ROOT/fabric-config/crypto-config/"

  printItalics "Generating crypto material for Dinas" "U1F512"
  certsGenerate "$FABLO_NETWORK_ROOT/fabric-config" "crypto-config-dinas.yaml" "peerOrganizations/dinas.palmmapping.co.id" "$FABLO_NETWORK_ROOT/fabric-config/crypto-config/"

  printItalics "Generating genesis block for group palmmapping-orderer-group" "U1F3E0"
  genesisBlockCreate "$FABLO_NETWORK_ROOT/fabric-config" "$FABLO_NETWORK_ROOT/fabric-config/config" "Palmmapping-orderer-groupGenesis"

  # Create directory for chaincode packages to avoid permission errors on linux
  mkdir -p "$FABLO_NETWORK_ROOT/fabric-config/chaincode-packages"
}

startNetwork() {
  printHeadline "Starting network" "U1F680"
  (cd "$FABLO_NETWORK_ROOT"/fabric-docker && docker-compose up -d)
  sleep 4
}

generateChannelsArtifacts() {
  printHeadline "Generating config for 'pemetaan-hutan-channel'" "U1F913"
  createChannelTx "pemetaan-hutan-channel" "$FABLO_NETWORK_ROOT/fabric-config" "PemetaanHutanChannel" "$FABLO_NETWORK_ROOT/fabric-config/config"
}

installChannels() {
  printHeadline "Creating 'pemetaan-hutan-channel' on Dinas/peer0" "U1F63B"
  docker exec -i cli.dinas.palmmapping.co.id bash -c "source scripts/channel_fns.sh; createChannelAndJoinTls 'pemetaan-hutan-channel' 'DinasMSP' 'peer0.dinas.palmmapping.co.id:7041' 'crypto/users/Admin@dinas.palmmapping.co.id/msp' 'crypto/users/Admin@dinas.palmmapping.co.id/tls' 'crypto-orderer/tlsca.orderer.palmmapping.co.id-cert.pem' 'orderer0.palmmapping-orderer-group.orderer.palmmapping.co.id:7030';"

  printItalics "Joining 'pemetaan-hutan-channel' on  Dinas/peer1" "U1F638"
  docker exec -i cli.dinas.palmmapping.co.id bash -c "source scripts/channel_fns.sh; fetchChannelAndJoinTls 'pemetaan-hutan-channel' 'DinasMSP' 'peer1.dinas.palmmapping.co.id:7042' 'crypto/users/Admin@dinas.palmmapping.co.id/msp' 'crypto/users/Admin@dinas.palmmapping.co.id/tls' 'crypto-orderer/tlsca.orderer.palmmapping.co.id-cert.pem' 'orderer0.palmmapping-orderer-group.orderer.palmmapping.co.id:7030';"
}

installChaincodes() {
  if [ -n "$(ls "$CHAINCODES_BASE_DIR/./chaincodes/pemetaan-hutan-chaincode")" ]; then
    local version="1.0.0"
    printHeadline "Packaging chaincode 'pemetaan-hutan-chaincode'" "U1F60E"
    chaincodeBuild "pemetaan-hutan-chaincode" "node" "$CHAINCODES_BASE_DIR/./chaincodes/pemetaan-hutan-chaincode" "16"
    chaincodePackage "cli.dinas.palmmapping.co.id" "peer0.dinas.palmmapping.co.id:7041" "pemetaan-hutan-chaincode" "$version" "node" printHeadline "Installing 'pemetaan-hutan-chaincode' for Dinas" "U1F60E"
    chaincodeInstall "cli.dinas.palmmapping.co.id" "peer0.dinas.palmmapping.co.id:7041" "pemetaan-hutan-chaincode" "$version" "crypto-orderer/tlsca.orderer.palmmapping.co.id-cert.pem"
    chaincodeInstall "cli.dinas.palmmapping.co.id" "peer1.dinas.palmmapping.co.id:7042" "pemetaan-hutan-chaincode" "$version" "crypto-orderer/tlsca.orderer.palmmapping.co.id-cert.pem"
    chaincodeApprove "cli.dinas.palmmapping.co.id" "peer0.dinas.palmmapping.co.id:7041" "pemetaan-hutan-channel" "pemetaan-hutan-chaincode" "$version" "orderer0.palmmapping-orderer-group.orderer.palmmapping.co.id:7030" "" "false" "crypto-orderer/tlsca.orderer.palmmapping.co.id-cert.pem" ""
    printItalics "Committing chaincode 'pemetaan-hutan-chaincode' on channel 'pemetaan-hutan-channel' as 'Dinas'" "U1F618"
    chaincodeCommit "cli.dinas.palmmapping.co.id" "peer0.dinas.palmmapping.co.id:7041" "pemetaan-hutan-channel" "pemetaan-hutan-chaincode" "$version" "orderer0.palmmapping-orderer-group.orderer.palmmapping.co.id:7030" "" "false" "crypto-orderer/tlsca.orderer.palmmapping.co.id-cert.pem" "peer0.dinas.palmmapping.co.id:7041" "crypto-peer/peer0.dinas.palmmapping.co.id/tls/ca.crt" ""
  else
    echo "Warning! Skipping chaincode 'pemetaan-hutan-chaincode' installation. Chaincode directory is empty."
    echo "Looked in dir: '$CHAINCODES_BASE_DIR/./chaincodes/pemetaan-hutan-chaincode'"
  fi

}

installChaincode() {
  local chaincodeName="$1"
  if [ -z "$chaincodeName" ]; then
    echo "Error: chaincode name is not provided"
    exit 1
  fi

  local version="$2"
  if [ -z "$version" ]; then
    echo "Error: chaincode version is not provided"
    exit 1
  fi

  if [ "$chaincodeName" = "pemetaan-hutan-chaincode" ]; then
    if [ -n "$(ls "$CHAINCODES_BASE_DIR/./chaincodes/pemetaan-hutan-chaincode")" ]; then
      printHeadline "Packaging chaincode 'pemetaan-hutan-chaincode'" "U1F60E"
      chaincodeBuild "pemetaan-hutan-chaincode" "node" "$CHAINCODES_BASE_DIR/./chaincodes/pemetaan-hutan-chaincode" "16"
      chaincodePackage "cli.dinas.palmmapping.co.id" "peer0.dinas.palmmapping.co.id:7041" "pemetaan-hutan-chaincode" "$version" "node" printHeadline "Installing 'pemetaan-hutan-chaincode' for Dinas" "U1F60E"
      chaincodeInstall "cli.dinas.palmmapping.co.id" "peer0.dinas.palmmapping.co.id:7041" "pemetaan-hutan-chaincode" "$version" "crypto-orderer/tlsca.orderer.palmmapping.co.id-cert.pem"
      chaincodeInstall "cli.dinas.palmmapping.co.id" "peer1.dinas.palmmapping.co.id:7042" "pemetaan-hutan-chaincode" "$version" "crypto-orderer/tlsca.orderer.palmmapping.co.id-cert.pem"
      chaincodeApprove "cli.dinas.palmmapping.co.id" "peer0.dinas.palmmapping.co.id:7041" "pemetaan-hutan-channel" "pemetaan-hutan-chaincode" "$version" "orderer0.palmmapping-orderer-group.orderer.palmmapping.co.id:7030" "" "false" "crypto-orderer/tlsca.orderer.palmmapping.co.id-cert.pem" ""
      printItalics "Committing chaincode 'pemetaan-hutan-chaincode' on channel 'pemetaan-hutan-channel' as 'Dinas'" "U1F618"
      chaincodeCommit "cli.dinas.palmmapping.co.id" "peer0.dinas.palmmapping.co.id:7041" "pemetaan-hutan-channel" "pemetaan-hutan-chaincode" "$version" "orderer0.palmmapping-orderer-group.orderer.palmmapping.co.id:7030" "" "false" "crypto-orderer/tlsca.orderer.palmmapping.co.id-cert.pem" "peer0.dinas.palmmapping.co.id:7041" "crypto-peer/peer0.dinas.palmmapping.co.id/tls/ca.crt" ""

    else
      echo "Warning! Skipping chaincode 'pemetaan-hutan-chaincode' install. Chaincode directory is empty."
      echo "Looked in dir: '$CHAINCODES_BASE_DIR/./chaincodes/pemetaan-hutan-chaincode'"
    fi
  fi
}

runDevModeChaincode() {
  local chaincodeName=$1
  if [ -z "$chaincodeName" ]; then
    echo "Error: chaincode name is not provided"
    exit 1
  fi

  if [ "$chaincodeName" = "pemetaan-hutan-chaincode" ]; then
    local version="1.0.0"
    printHeadline "Approving 'pemetaan-hutan-chaincode' for Dinas (dev mode)" "U1F60E"
    chaincodeApprove "cli.dinas.palmmapping.co.id" "peer0.dinas.palmmapping.co.id:7041" "pemetaan-hutan-channel" "pemetaan-hutan-chaincode" "1.0.0" "orderer0.palmmapping-orderer-group.orderer.palmmapping.co.id:7030" "" "false" "" ""
    printItalics "Committing chaincode 'pemetaan-hutan-chaincode' on channel 'pemetaan-hutan-channel' as 'Dinas' (dev mode)" "U1F618"
    chaincodeCommit "cli.dinas.palmmapping.co.id" "peer0.dinas.palmmapping.co.id:7041" "pemetaan-hutan-channel" "pemetaan-hutan-chaincode" "1.0.0" "orderer0.palmmapping-orderer-group.orderer.palmmapping.co.id:7030" "" "false" "" "peer0.dinas.palmmapping.co.id:7041" "" ""

  fi
}

upgradeChaincode() {
  local chaincodeName="$1"
  if [ -z "$chaincodeName" ]; then
    echo "Error: chaincode name is not provided"
    exit 1
  fi

  local version="$2"
  if [ -z "$version" ]; then
    echo "Error: chaincode version is not provided"
    exit 1
  fi

  if [ "$chaincodeName" = "pemetaan-hutan-chaincode" ]; then
    if [ -n "$(ls "$CHAINCODES_BASE_DIR/./chaincodes/pemetaan-hutan-chaincode")" ]; then
      printHeadline "Packaging chaincode 'pemetaan-hutan-chaincode'" "U1F60E"
      chaincodeBuild "pemetaan-hutan-chaincode" "node" "$CHAINCODES_BASE_DIR/./chaincodes/pemetaan-hutan-chaincode" "16"
      chaincodePackage "cli.dinas.palmmapping.co.id" "peer0.dinas.palmmapping.co.id:7041" "pemetaan-hutan-chaincode" "$version" "node" printHeadline "Installing 'pemetaan-hutan-chaincode' for Dinas" "U1F60E"
      chaincodeInstall "cli.dinas.palmmapping.co.id" "peer0.dinas.palmmapping.co.id:7041" "pemetaan-hutan-chaincode" "$version" "crypto-orderer/tlsca.orderer.palmmapping.co.id-cert.pem"
      chaincodeInstall "cli.dinas.palmmapping.co.id" "peer1.dinas.palmmapping.co.id:7042" "pemetaan-hutan-chaincode" "$version" "crypto-orderer/tlsca.orderer.palmmapping.co.id-cert.pem"
      chaincodeApprove "cli.dinas.palmmapping.co.id" "peer0.dinas.palmmapping.co.id:7041" "pemetaan-hutan-channel" "pemetaan-hutan-chaincode" "$version" "orderer0.palmmapping-orderer-group.orderer.palmmapping.co.id:7030" "" "false" "crypto-orderer/tlsca.orderer.palmmapping.co.id-cert.pem" ""
      printItalics "Committing chaincode 'pemetaan-hutan-chaincode' on channel 'pemetaan-hutan-channel' as 'Dinas'" "U1F618"
      chaincodeCommit "cli.dinas.palmmapping.co.id" "peer0.dinas.palmmapping.co.id:7041" "pemetaan-hutan-channel" "pemetaan-hutan-chaincode" "$version" "orderer0.palmmapping-orderer-group.orderer.palmmapping.co.id:7030" "" "false" "crypto-orderer/tlsca.orderer.palmmapping.co.id-cert.pem" "peer0.dinas.palmmapping.co.id:7041" "crypto-peer/peer0.dinas.palmmapping.co.id/tls/ca.crt" ""

    else
      echo "Warning! Skipping chaincode 'pemetaan-hutan-chaincode' upgrade. Chaincode directory is empty."
      echo "Looked in dir: '$CHAINCODES_BASE_DIR/./chaincodes/pemetaan-hutan-chaincode'"
    fi
  fi
}

notifyOrgsAboutChannels() {
  printHeadline "Creating new channel config blocks" "U1F537"
  createNewChannelUpdateTx "pemetaan-hutan-channel" "DinasMSP" "PemetaanHutanChannel" "$FABLO_NETWORK_ROOT/fabric-config" "$FABLO_NETWORK_ROOT/fabric-config/config"

  printHeadline "Notyfing orgs about channels" "U1F4E2"
  notifyOrgAboutNewChannelTls "pemetaan-hutan-channel" "DinasMSP" "cli.dinas.palmmapping.co.id" "peer0.dinas.palmmapping.co.id" "orderer0.palmmapping-orderer-group.orderer.palmmapping.co.id:7030" "crypto-orderer/tlsca.orderer.palmmapping.co.id-cert.pem"

  printHeadline "Deleting new channel config blocks" "U1F52A"
  deleteNewChannelUpdateTx "pemetaan-hutan-channel" "DinasMSP" "cli.dinas.palmmapping.co.id"
}

printStartSuccessInfo() {
  printHeadline "Done! Enjoy your fresh network" "U1F984"
}

stopNetwork() {
  printHeadline "Stopping network" "U1F68F"
  (cd "$FABLO_NETWORK_ROOT"/fabric-docker && docker-compose stop)
  sleep 4
}

networkDown() {
  printHeadline "Destroying network" "U1F916"
  (cd "$FABLO_NETWORK_ROOT"/fabric-docker && docker-compose down)

  printf "Removing chaincode containers & images... \U1F5D1 \n"
  for container in $(docker ps -a | grep "dev-peer0.dinas.palmmapping.co.id-pemetaan-hutan-chaincode" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer0.dinas.palmmapping.co.id-pemetaan-hutan-chaincode*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done
  for container in $(docker ps -a | grep "dev-peer1.dinas.palmmapping.co.id-pemetaan-hutan-chaincode" | awk '{print $1}'); do
    echo "Removing container $container..."
    docker rm -f "$container" || echo "docker rm of $container failed. Check if all fabric dockers properly was deleted"
  done
  for image in $(docker images "dev-peer1.dinas.palmmapping.co.id-pemetaan-hutan-chaincode*" -q); do
    echo "Removing image $image..."
    docker rmi "$image" || echo "docker rmi of $image failed. Check if all fabric dockers properly was deleted"
  done

  printf "Removing generated configs... \U1F5D1 \n"
  rm -rf "$FABLO_NETWORK_ROOT/fabric-config/config"
  rm -rf "$FABLO_NETWORK_ROOT/fabric-config/crypto-config"
  rm -rf "$FABLO_NETWORK_ROOT/fabric-config/chaincode-packages"

  printHeadline "Done! Network was purged" "U1F5D1"
}
