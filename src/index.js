import { createApp } from "@deroll/app";
import { encodeFunctionData, getAddress, hexToString } from "viem";
import votingContractAbi from "./votingAbi.json";
var voting_contract_address = "";

// Create the application
const app = createApp({
    url: process.env.ROLLUP_HTTP_SERVER_URL || "http://127.0.0.1:5004",
});

// Handle input encoded in hex
app.addAdvanceHandler(async ({ metadata, payload }) => {
    const payloadString = hexToString(payload);
    console.log("payload:", payloadString);
    const jsonPayload = JSON.parse(payloadString);
    const sender = metadata.msg_sender;
    console.log("sender : ", sender);

    if (jsonPayload.method === "set_address") {
        voting_contract_address = getAddress(jsonPayload.address);
        console.log("Voting contract address is now set", voting_contract_address);
    } else if (jsonPayload.method === "vote") {
        const candidateId = jsonPayload.candidateId;

        // Prepare voucher for the vote
        const callData = encodeFunctionData({
            abi: votingContractAbi,
            functionName: "vote",
            args: [candidateId]
        });

        // Generate voucher
        app.createVoucher({ destination: voting_contract_address, payload: callData });
    }

    return "accept";
});

// Start the application
app.start().catch((e) => {
    console.error(e);
    process.exit(1);
});
