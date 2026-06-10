export function analyzeResponse(data: any): {
  tokenPath: string | null
  tokenValue: any
  isSuccess: boolean
  details: string
} {
  const paths = [
    'data.token',
    'data.accessToken',
    'data.idToken',
    'token',
    'accessToken',
    'idToken',
    'result.token',
    'result.accessToken',
    'result.idToken'
  ]

  let tokenValue: any = null
  let tokenPath: string | null = null

  for (const path of paths) {
    const keys = path.split('.')
    let value: any = data

    for (const key of keys) {
      if (value && typeof value === 'object' && key in value) {
        value = value[key]
      } else {
        value = undefined
        break
      }
    }

    if (value && typeof value === 'string' && value.length > 10) {
      tokenValue = value
      tokenPath = path
      break
    }
  }

  const isSuccess = data.code === 200 || data.code === 0 || data.success === true || data.status === 'success' || !!tokenValue

  return {
    tokenPath,
    tokenValue,
    isSuccess,
    details: JSON.stringify(data, null, 2).substring(0, 500)
  }
}
