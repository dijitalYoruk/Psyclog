const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const WalletSchema = new Schema(
    {
        cash: {
            min: 0,
            default: 0,
            type: Number,
            required: true
        },
        owner: {
            ref: "User",
            type: mongoose.Schema.ObjectId,
            required: [true, "You should have a wallet owner."],
        },
    },
    { timestamps: true, versionKey: false }
);


const Wallet = mongoose.model("Wallet", WalletSchema);
module.exports = Wallet;
