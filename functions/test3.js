async function run() {
  console.log('Starting...');
  try {
    console.log('Importing node:fs');
    await import('node:fs');
    console.log('Importing firebase-functions/v2/https');
    await import('firebase-functions/v2/https');
    console.log('Importing firebase-functions/v2/scheduler');
    await import('firebase-functions/v2/scheduler');
    console.log('Importing firebase-admin/app');
    await import('firebase-admin/app');
    console.log('Importing firebase-admin/messaging');
    await import('firebase-admin/messaging');
    console.log('Done!');
  } catch (err) {
    console.error(err);
  }
  process.exit(0);
}
run();
