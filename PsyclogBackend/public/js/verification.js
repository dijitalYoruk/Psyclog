/*eslint-disable*/

const button = document.getElementById('post-btn');
const url = document.getElementById('post-btn').value;

button.addEventListener('click', async _ => {
    console.log(url)
  try {     
    const response = await fetch(url, {
      method: 'post',
      body: {
      }
    });
    console.log('Completed!', response);
  } catch(err) {
    console.error(`Error: ${err}`);
  }
});