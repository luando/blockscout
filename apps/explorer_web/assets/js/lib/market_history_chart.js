import Chart from 'chart.js'
import humps from 'humps'
import moment from 'moment'
import numeral from 'numeral'
import sassVariables from '../../css/app.scss'

const config = {
  type: 'line',
  responsive: true,
  data: {
    datasets: []
  },
  options: {
    legend: {
      display: false
    },
    scales: {
      xAxes: [{
        gridLines: {
          display: false,
          drawBorder: false
        },
        type: 'time',
        time: {
          unit: 'day',
          stepSize: 14,
          displayFormats: {
            week: 'MMM D'
          }
        }
      }],
      yAxes: [{
        id: 'price',
        gridLines: {
          display: false,
          drawBorder: false
        },
        ticks: {
          beginAtZero: true,
          callback: (value, index, values) => formatPrice(value),
          maxTicksLimit: 4
        }
      }, {
        id: 'marketCap',
        position: 'right',
        gridLines: {
          display: false,
          drawBorder: false
        },
        ticks: {
          callback: (value, index, values) => '',
          maxTicksLimit: 6,
          drawOnChartArea: false
        }
      }]
    },
    tooltips: {
      mode: 'index',
      intersect: false,
      callbacks: {
        label: ({datasetIndex, yLabel}, {datasets}) => {
          const label = datasets[datasetIndex].label
          if (datasets[datasetIndex].label === 'Price') {
            return `${label}: ${formatPrice(yLabel)}`
          } else if (datasets[datasetIndex].label === 'Market Cap') {
            return `${label}: ${formatMarketCap(yLabel)}`
          } else {
            return yLabel
          }
        }
      }
    }
  }
}

function formatPrice (price) {
  return '$' + price.toFixed(2)
}

function formatMarketCap (marketCap) {
  return numeral(marketCap).format('($0,0a)')
}

function getCurrentMarketHistoryData (currentExchangeRate, marketHistoryData) {
  const today = moment().format('YYYY-MM-DD')
  return marketHistoryData.map(({date, closingPrice}) => ({
    date,
    closingPrice: date === today ? currentExchangeRate : closingPrice
  }))
}

function getPriceData (currentMarketHistoryData) {
  return currentMarketHistoryData.map(({ date, closingPrice }) => ({x: date, y: closingPrice}))
}

function getMarketCapData (currentMarketHistoryData, availableSupply) {
  return currentMarketHistoryData.map(({ date, closingPrice }) => ({x: date, y: closingPrice * availableSupply}))
}

class MarketHistoryChart {
  constructor (el, currentExchangeRate, availableSupply, marketHistoryData) {
    const currentMarketHistoryData = getCurrentMarketHistoryData(currentExchangeRate, marketHistoryData)

    this.price = {
      label: 'Price',
      yAxisID: 'price',
      data: getPriceData(currentMarketHistoryData),
      fill: false,
      pointRadius: 0,
      backgroundColor: sassVariables.primary,
      borderColor: sassVariables.primary,
      lineTension: 0
    }
    this.marketCap = {
      label: 'Market Cap',
      yAxisID: 'marketCap',
      data: getMarketCapData(currentMarketHistoryData, availableSupply),
      fill: false,
      pointRadius: 0,
      backgroundColor: sassVariables.secondary,
      borderColor: sassVariables.secondary,
      lineTension: 0
    }
    config.data.datasets = [this.price, this.marketCap]
    this.chart = new Chart(el, config)
  }
}

export function createMarketHistoryChart (ctx) {
  const currentExchangeRate = ctx.dataset.current_exchange_rate
  const availableSupply = ctx.dataset.available_supply
  const marketHistoryData = humps.camelizeKeys(JSON.parse(ctx.dataset.market_history_data))

  return new MarketHistoryChart(ctx, currentExchangeRate, availableSupply, marketHistoryData)
}
