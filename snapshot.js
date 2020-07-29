const PercyScript = require('@percy/script');
const httpServer = require('http-server');

const TEST_URL = `http://0.0.0.0:4567/documentation/3.8/rspec-core/`;

// A script to navigate our app and take snapshots with Percy.
PercyScript.run(async (page, percySnapshot) => {
  let server = httpServer.createServer();
  server.listen(PORT);

  console.log(`Server started at ${TEST_URL}`);

  await page.goto(TEST_URL);
  await percySnapshot('rspec-core 3.8');
  server.close();
});
