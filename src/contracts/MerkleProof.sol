// SPDX-License-Identifier: MIT  
pragma solidity^0.8.10;

contract MerkleProof{
    bytes32[] public hashes;
    uint256 public count;
    function inputTransaction(string[] memory _transactions)public{
        count =_transactions.length;
        for(uint i=0; i<count; i++){
            hashes.push(keccak256(abi.encodePacked(_transactions[i])));
        }
        createMerkleTree();
    }
    function createMerkleTree() private{
        uint n =hashes.length;
        uint offset=0;
        while(n>0){
            for(uint i=0; i<n-1; i+=2){
                hashes.push(keccak256(abi.encodePacked(hashes[offset+i],hashes[offset+i+1])));
            }
            offset+=n;
            n=n/2;
        }
    }
    // you passed hashes array [t0, t23] and index 0; 
    function verify(uint index, bytes32 leaf) public view returns(bool){
        bytes32[] memory hashArray=getHashArray(index);
        bytes32 hash =leaf;
        for(uint i=0; i<hashArray.length; i++){
            bytes32 currentHash = hashArray[i];
            if(index % 2 == 0){
                hash =keccak256(abi.encodePacked(hash,currentHash));
            }else{
                hash =keccak256(abi.encodePacked(currentHash,hash));
            }
            index =index/2;
        }
        bytes32 rootHash =getRoot();
        if(rootHash==hash) return true;
        return false;
    }
    function getHashArray(uint256 index) private view returns(bytes32[] memory ){
        uint counter =log2(count);
        bytes32[] memory hashArray= new bytes32[](counter);
        
        for(uint i=0; i< counter; i++){
            if( index % 2 == 0){
                hashArray[i] =hashes[index+1];
                
            }else{
                hashArray[i] =hashes[index-1];
                
            }          
            index =(index / 2)+count;  
        }
        return hashArray;          
    }                                      
    function log2(uint x) private pure returns (uint y){
    assembly {
            let arg := x
            x := sub(x,1)
            x := or(x, div(x, 0x02))
            x := or(x, div(x, 0x04))
            x := or(x, div(x, 0x10))
            x := or(x, div(x, 0x100))
            x := or(x, div(x, 0x10000))
            x := or(x, div(x, 0x100000000))
            x := or(x, div(x, 0x10000000000000000))
            x := or(x, div(x, 0x100000000000000000000000000000000))
            x := add(x, 1)
            let m := mload(0x40)
            mstore(m,           0xf8f9cbfae6cc78fbefe7cdc3a1793dfcf4f0e8bbd8cec470b6a28a7a5a3e1efd)
            mstore(add(m,0x20), 0xf5ecf1b3e9debc68e1d9cfabc5997135bfb7a7a3938b7b606b5b4b3f2f1f0ffe)
            mstore(add(m,0x40), 0xf6e4ed9ff2d6b458eadcdf97bd91692de2d4da8fd2d0ac50c6ae9a8272523616)
            mstore(add(m,0x60), 0xc8c0b887b0a8a4489c948c7f847c6125746c645c544c444038302820181008ff)
            mstore(add(m,0x80), 0xf7cae577eec2a03cf3bad76fb589591debb2dd67e0aa9834bea6925f6a4a2e0e)
            mstore(add(m,0xa0), 0xe39ed557db96902cd38ed14fad815115c786af479b7e83247363534337271707)
            mstore(add(m,0xc0), 0xc976c13bb96e881cb166a933a55e490d9d56952b8d4e801485467d2362422606)
            mstore(add(m,0xe0), 0x753a6d1b65325d0c552a4d1345224105391a310b29122104190a110309020100)
            mstore(0x40, add(m, 0x100))
            let magic := 0x818283848586878898a8b8c8d8e8f929395969799a9b9d9e9faaeb6bedeeff
            let shift := 0x100000000000000000000000000000000000000000000000000000000000000
            let a := div(mul(x, magic), shift)
            y := div(mload(add(m,sub(255,a))), shift)
            y := add(y, mul(256, gt(arg, 0x8000000000000000000000000000000000000000000000000000000000000000)))
        }  
    }
    function getHashes() public view returns(bytes32[] memory){
        return hashes;
    }
    function getRoot() public view returns(bytes32){
        return hashes[hashes.length-1];
    }
}

// ["1","2","3","4","5","6","7","8"]
// 0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6,
// 0xad7c5bef027816a800da1736444fb58a807ef4c9603b7848673f7e3a68eb14a5,
// 0x2a80e1ef1d7842f27f2e6be0972bb708b9a135c38860dbe73c27c3486c34f4de,
// 0x13600b294191fc92924bb3ce4b969c1e7e2bab8f4c93c3fc6d0a51733df3c060,
// 0xceebf77a833b30520287ddd9478ff51abbdffa30aa90a8d655dba0e8a79ce0c1,
// 0xe455bf8ea6e7463a1046a0b52804526e119b4bf5136279614e0b1e8e296a4e2d,
// 0x52f1a9b320cab38e5da8a8f97989383aab0a49165fc91c737310e4f7e9821021,
// 0xe4b1702d9298fee62dfeccc57d322a463ad55ca201256d01f62b45b2e1c21c10

// 0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6,
// 0xad7c5bef027816a800da1736444fb58a807ef4c9603b7848673f7e3a68eb14a5,
// 0x2a80e1ef1d7842f27f2e6be0972bb708b9a135c38860dbe73c27c3486c34f4de,
// 0x13600b294191fc92924bb3ce4b969c1e7e2bab8f4c93c3fc6d0a51733df3c060,
// 0xceebf77a833b30520287ddd9478ff51abbdffa30aa90a8d655dba0e8a79ce0c1,
// 0xe455bf8ea6e7463a1046a0b52804526e119b4bf5136279614e0b1e8e296a4e2d,
// 0x52f1a9b320cab38e5da8a8f97989383aab0a49165fc91c737310e4f7e9821021,
// 0xe4b1702d9298fee62dfeccc57d322a463ad55ca201256d01f62b45b2e1c21c10,

// 0x08629ae32294b0f0b9b75732d124f37e3f1e88c67028c8fb63f5280d11945961,
// 0x530ffcc8ace434febd23d08b521c5901cc2767865b583fb01942f324c6737cf5,
// 0xd5f2cc77b02cdfeeb0101a2ef46f583e4a552fe89616f7db273cdb510df4f3d9,
// 0x44175ac6cd3e7987890f2ca00885c7a88da8e29eac5defa009b73687964e08a0,

// 0x0d498b4e4bf2c63430c21419d50b819372e1d6e0dcb411c3a973090b608e44cb,
// 0x8a1b2d8c1b806052a0e1c34a2e709f069f669d40187da89d26569d339317d155,

// 0x9578ec9a51e85e5c287e3bccec1bcec9f0de5d05717e8b932190370da9d86d72

// [t0,t1,t2,t3,t01,t23,t0123]
// ["0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6","0x530ffcc8ace434febd23d08b521c5901cc2767865b583fb01942f324c6737cf5"],1,"0xad7c5bef027816a800da1736444fb58a807ef4c9603b7848673f7e3a68eb14a5"]

// OUTPUT GETHASHARRAY
// 0xad7c5bef027816a800da1736444fb58a807ef4c9603b7848673f7e3a68eb14a5,
// 0x530ffcc8ace434febd23d08b521c5901cc2767865b583fb01942f324c6737cf5,
// 0x8a1b2d8c1b806052a0e1c34a2e709f069f669d40187da89d26569d339317d155