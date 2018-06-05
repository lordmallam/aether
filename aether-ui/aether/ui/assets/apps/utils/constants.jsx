// `1048576` is the maximum value accepted by the pagination class
// Total number of rows on a worksheet (since Excel 2007)
// https://support.office.com/en-us/article/Excel-specifications-and-limits-1672b34d-7043-467e-8e27-269d656771c3
// the first row would be the header so we reduce in one the value.
export const MAX_PAGE_SIZE = 1048575
export const PROJECT_NAME = 'AUX'