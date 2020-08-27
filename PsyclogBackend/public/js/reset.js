/*eslint-disable*/

const reset= async (password,passwordConfirm,token,url)=>{
    try{
        const res= await axios({
            method:'PATCH',
            url: url,
            data:{
                password,
                passwordConfirm,
                token
            }
        });
        console.log(res);
    }catch (err) {
        console.log( err.response.data);

    }

};


document.querySelector('form').addEventListener('submit',e=>{
    e.preventDefault();
    const password=document.getElementById('password').value;
    const passwordConfirm=document.getElementById('passwordConfirm').value;
    const token=document.getElementById('token').value;
    const url = `/api/v1/auth/reset-password`;
    if (password != passwordConfirm) {
        alert("Passwords do not match. Try again.");
    }else{
        reset(password,passwordConfirm,token,url);
    }   
});

var check = function() {
    if (document.getElementById('password').value ==
      document.getElementById('passwordConfirm').value) {
      document.getElementById('message').style.color = 'green';
      document.getElementById('message').innerHTML = 'matching';
    } else {
      document.getElementById('message').style.color = 'red';
      document.getElementById('message').innerHTML = 'not matching';
    }
  }
