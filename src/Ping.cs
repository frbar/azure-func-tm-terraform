using System.Collections.Generic;
using System.Linq;
using System.Net;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

namespace Frbar.DemoFunction
{
    public class Ping
    {
        private readonly ILogger _logger;

        public Ping(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<Ping>();
        }

        [Function("ping")]
        public HttpResponseData Run([HttpTrigger(AuthorizationLevel.Anonymous, "get", "post")] HttpRequestData req)
        {
            _logger.LogInformation("C# HTTP trigger function processed a request.");

            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "text/plain; charset=utf-8");

            var headers = string.Empty;
            foreach(var header in req.Headers.ToList())
            {
                response.WriteString($"{header.Key} = {header.Value.First()}{Environment.NewLine}");
            }           

            return response;
        }
    }
}
