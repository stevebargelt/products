using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;

namespace products.Controllers
{
    [Route(Endpoint)]
    public class ProductsController : Controller
    {
        public const string Endpoint = "v1/products";
        
        [HttpGet]
        public IEnumerable<string> Get()
        {
            return new string[] { "product1", "product2", "product3", "product4", "product5" };
        }

        // GET v1/products/1
        [HttpGet("{id}")]
        public string Get(int id)
        {
            return "product" + id.ToString();
        }

    }
}
