import { useState, useEffect } from 'react';
import { naming_backend } from 'declarations/naming_backend';

function App() {
  const [nameCount, setNameCount] = useState(null);
  const [totalSubmissions, setTotalSubmissions] = useState(0);
  const [allNames, setAllNames] = useState([]);
  const [icpUsdExchange, setIcpUsdExchange] = useState('');

  useEffect(() => {
    updateTotalSubmissions();
    updateAllNames();
    updateIcpUsdExchange();
  }, []);

  function updateTotalSubmissions() {
    naming_backend.getTotalSubmissions().then(setTotalSubmissions);
  }

  async function updateIcpUsdExchange() {
    try {
      const exchangeData = await naming_backend.get_icp_usd_exchange();
      setIcpUsdExchange(exchangeData);
    } catch (error) {
      console.error('Error fetching ICP-USD exchange rate:', error);
      setIcpUsdExchange('Error fetching exchange rate');
    }
  }

  function updateAllNames() {
    naming_backend.getAllNames().then(setAllNames);
  }

  async function handleSubmit(event) {
    event.preventDefault();
    const name = event.target.elements.name.value;
    
    try {
      const count = await naming_backend.submitName(name);
      setNameCount(Number(count));

      await updateTotalSubmissions();
      await updateAllNames();

      event.target.elements.name.value = '';
    } catch (error) {
      console.error('Error submitting name:', error);
    }
  }

  return (
    <main>
      <h1>Name Counter</h1>
      <form onSubmit={handleSubmit}>
        <div>
          <label htmlFor="name">Enter your name: </label>
          <input id="name" type="text" required />
        </div>
        <button type="submit">Submit</button>
      </form>
      {nameCount !== null && (
        <section id="nameCount">
          <h2>Name Statistics:</h2>
          <p>Your name has been submitted {Number(nameCount)} times</p>
        </section>
      )}
      <section id="totalSubmissions">
        <p>Total name submissions: {Number(totalSubmissions)}</p>
      </section>
      <section id="allNames">
        <h2>List of All Names:</h2>
        <ul>
          {allNames.map(([name, count]) => (
            <li key={name}>{name}: {Number(count)} times</li>
          ))}
        </ul>
      </section>
      <section id="icpUsdExchange">
        <h2>ICP-USD Exchange Rate:</h2>
        <p>{icpUsdExchange}</p>
        <button onClick={updateIcpUsdExchange}>Refresh Exchange Rate</button>
      </section>
    </main>
  );
}

export default App;