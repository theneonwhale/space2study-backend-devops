const client = require('prom-client');
const responseTime = require('response-time');

/**
 * Prometheus Metrics Middleware
 *
 * This middleware sets up a /metrics endpoint for Prometheus to scrape.
 * It also collects default metrics and custom API metrics like response time.
 */

// Create a Registry to register the metrics
const register = new client.Registry();

// Collect default metrics (like CPU and memory usage)
client.collectDefaultMetrics({ register });

// Define a histogram metric for tracking response times of API requests
const httpRequestDurationMicroseconds = new client.Histogram({
  name: 'http_request_duration_ms',
  help: 'Duration of HTTP requests in ms',
  labelNames: ['method', 'route', 'code'],
  buckets: [50, 100, 200, 300, 400, 500, 750, 1000, 2500, 5000], // buckets for response time from 50ms to 5s
});

// Register the histogram
register.registerMetric(httpRequestDurationMicroseconds);

// Middleware to track response times
const metricsMiddleware = responseTime((req, res, time) => {
  if (req.route?.path) {
    httpRequestDurationMicroseconds.observe(
      {
        method: req.method,
        route: req.route.path,
        code: res.statusCode,
      },
      time
    );
  }
});

// Middleware to expose the /metrics endpoint
const exposeMetricsMiddleware = async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
};

module.exports = {
  metricsMiddleware,
  exposeMetricsMiddleware,
};
