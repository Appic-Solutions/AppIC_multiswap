import Blob "mo:base/Blob";
import A "./Account";
import SHA224 "./SHA224";
import Buffer "mo:base/Buffer";
module {

    public type GenerateSubaccountArgs = {
        caller : Principal;
        id : Nat;
    };

    public func defaultSubAccount() : Blob {
        var index : Nat8 = 0;
        return Blob.fromArray([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, index]);
    };

    public func generateSubaccount(args : GenerateSubaccountArgs) : Blob {
        let idHash = SHA224.Digest();
        // Length of domain separator
        idHash.write([0x0A]);
        // Domain separator
        idHash.write(Blob.toArray(Text.encodeUtf8("invoice-id")));
        // Counter as Nonce
        let idBytes = A.beBytes(Nat32.fromNat(args.id));
        idHash.write(idBytes);
        // Principal of caller
        idHash.write(Blob.toArray(Principal.toBlob(args.caller)));
        let hashSum = idHash.sum();
        let crc32Bytes = A.beBytes(CRC32.ofArray(hashSum));
        let buf = Buffer.Buffer<Nat8>(32);
        Blob.fromArray(Array.append(crc32Bytes, hashSum));
    };
};
