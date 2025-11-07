import React, {useState} from 'react';

export default function App(){
  const [cedula,setCedula] = useState('');
  const [result,setResult] = useState(null);
  async function buscar(e){
    e.preventDefault();
    setResult('Loading...');
    try{
      const resp = await fetch(`${process.env.REACT_APP_API_URL || 'http://backend-api:8080'}/person/${cedula}`);
      if(!resp.ok) throw new Error('Not found');
      const data = await resp.json();
      setResult(data);
    }catch(err){
      setResult({error: err.message});
    }
  }
  return (<div style={{padding:20,fontFamily:'Arial'}}>
    <h2>Buscar nombre por cédula</h2>
    <form onSubmit={buscar}>
      <input placeholder="Cédula" value={cedula} onChange={e=>setCedula(e.target.value)} />
      <button type="submit">Buscar</button>
    </form>
    <pre style={{marginTop:20}}>{JSON.stringify(result, null, 2)}</pre>
  </div>);
}
