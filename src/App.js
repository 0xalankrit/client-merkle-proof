import {useEffect,useState} from 'react';
import {Form ,Button,Container,Row, Col} from 'react-bootstrap';
import {ethers} from 'ethers';
import MerkleProof from './build/MerkleProof.json';
import { ToastContainer, toast } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import './App.css';

function App() {
  const [account, setaccount] = useState('0x0');
  const [arrayOfTransactions, setarrayOfTransactions] = useState([]);
  const [queryInputIndex, setqueryInputIndex] = useState('')
  const [queryInputTx, setqueryInputTx] = useState('');

  const [provider, setprovider] = useState(null);
  const [signer, setsigner] = useState(null);
  const [contract, setcontract] = useState(null);

  useEffect(async() => {
    if(window.ethereum===undefined){
      window.alert('Please Install Metamask');
    }

    const connectAccount= async() =>{
      try {
        const accounts =await window.ethereum.request({method:'eth_requestAccounts'});
        setaccount(accounts[0]);
      } catch (error) {
        console.log(error.message)
      }
    }
    const accountWasChanged = (accounts) => {
      setaccount(accounts[0]);
    }
    const disconnectAccount = ()=>{
      setaccount('0x0');
    }
    window.ethereum.on('accountsChanged', accountWasChanged);
    window.ethereum.on('connect',connectAccount);
    window.ethereum.on('disconnect',disconnectAccount);
    
    const provider =new ethers.providers.Web3Provider(window.ethereum);
    setprovider(provider);
    const signer =provider.getSigner();
    setsigner(signer);

    const contractAddress =MerkleProof.networks["5777"].address;
    const contractInstance =new ethers.Contract(contractAddress,MerkleProof.abi,signer);
    setcontract(contractInstance);

    return  ()=>{
      window.ethereum.off('accountsChanged',accountWasChanged);
      window.ethereum.off('connect',connectAccount);
      window.ethereum.off('disconnect',disconnectAccount);
    }
  }, [])
  const submitArray=async(e)=>{
    e.preventDefault();
    arrayOfTransactions.slice(0, -1)
    arrayOfTransactions.slice(0, 1)
    let newArray ="";
    for(let i=2; i<arrayOfTransactions.length-2; i++){
      newArray += arrayOfTransactions[i]
    }
    const arrarray2 =newArray.split('","');
    const transaction = await contract.inputTransaction(arrarray2);
    const receipt =await transaction.wait();
    // console.log(receipt);
  }
  const submitQuery=async(e)=>{
    e.preventDefault();

    try {
      const result =await contract.verify(queryInputIndex,ethers.utils.hexlify(queryInputTx));
      if(result===true){
        toast.success('🦄 Your transaction is contained in the set of transactions', {
          position: "top-right",
          autoClose: 5000,
          hideProgressBar: false,
          closeOnClick: true,
          pauseOnHover: true,
          draggable: true,
          progress: undefined,
          });
      }else{
        toast.error('🦄 Your transaction is not contained in the set of transactions', {
          position: "top-right",
          autoClose: 5000,
          hideProgressBar: false,
          closeOnClick: true,
          pauseOnHover: true,
          draggable: true,
          progress: undefined,
          });
      }
    } catch (error) {
        console.log(error.message); 
    }
  }
  // 0,0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6
  return (
    <div className="App">
       <ToastContainer
        position="top-right"
        autoClose={5000}
        hideProgressBar={false}
        newestOnTop={false}
        closeOnClick
        rtl={false}
        pauseOnFocusLoss
        draggable
        pauseOnHover
        />
        <ToastContainer />
        <br></br>
        <h3>{account}</h3>
        <br></br>
        <Container>

        <Form onSubmit={submitArray}>
              <Form.Group className="mb-3" controlId="formBasicEmail">
                <Form.Control value={arrayOfTransactions} onChange={(e)=>{setarrayOfTransactions(e.target.value)}} type="text" placeholder="Enter array of Transactions" />
              </Form.Group>
                <Button variant="dark" type="submit">
                Submit
              </Button>
        </Form>
        <br></br>
        <Form onSubmit={submitQuery}>

              <Form.Group className="mb-3" controlId="formBasicEmail">
                <Form.Control value ={queryInputIndex} onChange={(e)=>{setqueryInputIndex(e.target.value)}} type="number" placeholder="Enter your transaction index" />
              </Form.Group>
              <Form.Group className="mb-3" controlId="formBasicEmail">
                <Form.Control value ={queryInputTx} onChange={(e)=>{setqueryInputTx(e.target.value)}} type="text" placeholder="Enter your transaction" />
              </Form.Group>

                <Button variant="dark" type="submit">
                Submit
              </Button>

        </Form>

        </Container>
    </div>
  );
}

export default App;
