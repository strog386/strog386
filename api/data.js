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
  ssl: {
    rejectUnauthorized: false  // Allow SSL connections (useful for some managed PostgreSQL servers)
  },  // Ensure SSL is enabled for Supabase connection
});


client.connect()
  .then(() => console.log('Connected to PostgreSQL'))
  .catch(err => console.error('Connection error', err.stack));


app.post('/data', (req, res) => {
  const { orderNr } = req.body; 

  const query = `
  SELECT 
  public.orp.OrderNr, 
  public.orp.ItemNumber, 
  public.ar.ItemDescription, 
  public.ar.SmallText, 
  public.ar.PickAreaNr, 
  public.gatx.PickAreaName, 
  public.oh.PlantDate
FROM 
  public.orp  
JOIN 
  public.ar 
ON 
  orp.ItemNumber = ar.Item_Number
JOIN 
  public.gatx 
ON 
  ar.PickAreaNr = gatx.PickAreaNr
JOIN 
  public.oh 
ON 
  orp.OrderNr = oh.OrderNr
WHERE 
  orp.OrderNr = $1;
`;


  client.query(query, [orderNr], (err, result) => {
    if (err) {
      console.error(err);
      res.status(500).send('Error fetching data');
    } else {
      const data = result.rows.map(row => ({
      OrderNr: row.ordernr ? row.ordernr.toString() : '',
      ItemNumber: row.itemnumber ? row.itemnumber.toString() : '',
      ItemDescription: row.itemdescription ? row.itemdescription.toString() : '',
      SmallText: row.smalltext ? row.smalltext.toString() : '',
      PickAreaNr: row.pickareanr ? row.pickareanr.toString() : '',
      PickAreaName: row.pickareaname ? row.pickareaname.toString() : '',
      PlantDate: row.plantdate ? row.plantdate.toISOString().split('T')[0] : '' // Handle null values
      }));
      res.json(data);
    }
  });
});

export default async (req, res) => {
  // Vercel serverless function handler
  if (req.method === 'POST') {
    // Use express to handle POST request
    await new Promise((resolve) => {
      app(req, res, resolve);  // Call express app as middleware
    });
  } else {
    res.status(405).send('Method Not Allowed');
  }
};

