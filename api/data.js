import express from 'express';
import cors from 'cors';
import { createRequire } from 'module';
const require = createRequire(import.meta.url);
const { Client } = require('pg');
const app = express();

app.use(cors());
app.use(express.json()); 

const client = new Client({
  host: 'aws-0-ca-central-1.pooler.supabase.com',  // e.g. 'db.xyz.supabase.co'
  port: 6543,                     // Supabase PostgreSQL port
  user: 'postgres.tuxoockqaksayeeasmib',  // e.g. 'postgres'
  password: 'Redstr900@@',
  database: 'postgres', // e.g. 'postgres'
    // Ensure SSL is enabled for Supabase connection
});

try{
client.connect()
  .then(() => console.log('Connected to PostgreSQL'))
  .catch(err => console.error('Connection error', err.stack));


app.post('/data', (req, res) => {
  const { orderNr } = req.body; 

  const query = `
  SELECT public.orp.OrderNr, public.orp.ItemNumber, public.ar.ItemDescription
  FROM public.orp  
  JOIN public.ar ON orp.ItemNumber = ar.Item_Number
  WHERE orp.OrderNr = $1
`;


  client.query(query, [orderNr], (err, result) => {
    if (err) {
      console.error(err);
      res.status(500).send('Error fetching data');
    } else {
      const data = result.rows.map(row => ({
        OrderNr: row.ordernr ? row.ordernr.toString() : '', 
        ItemNumber: row.itemnumber ? row.itemnumber.toString() : '', 
        ItemDescription: row.itemdescription ? row.itemdescription.toString() : '' // Handle null values
      }));
      res.json(data);
    }
  });
});

} catch (error) {
    console.error('Error:', error); // Log error for debugging
    res.status(500).send('Internal Server Error');
  } finally {
    // Close the database connection
    await client.end();
  }
