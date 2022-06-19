from model import *
from model.data import Data
        
class EmptySheetError(Exception):
    """Class for Preprocessing Error"""
    
    def __init__(self, empty_sheet = "One of the input sheets"):
        super().__init__(f"{empty_sheet} is empty. Please fill in the necessary data")

def get_timeframe():
    """
    Get optimization timeframe

    Outputs to data.py
    ------------------
    Data.timeframe: list
        - Pull from "Timeframe"

    """
    Data.timeframe = list(pd.read_excel(Data.filepath).iloc[0])

    assert Data.timeframe[1] - \
        Data.timeframe[0] >= 0, 'Timeframe cannot be descending'


def raw_inputs():
    """
    Pull data from input Excel files.

    Below only includes a shortlist of attributes used
    and the sheet where the data comes from. For detailed
    documentation, see Attributes.txt

    Outputs to data.py
    ------------------
    Data.product_list: list
        - Pull from "Product List"

    Data.factory_list: list
        - Pull from "Factory List"

    Data.factory_names: dict
        - Pull from "Factory Per Product"

    Data.inbound_cost_per_product: dict
        - Pull from "Inbound Cost Per Product"

    Data.demand_volume: numpy.ndarray
        - Pull from "Sales Volume"

    Data.outbound_cost_per_product: dict
        - Pull from "Outbound Cost"

    Data.efficiency_per_product: dict
        - Pull from "Efficiency Per Product"

    Data.capacity_constraints: list
        - Pull from "Capacity Constraints"

    Data.supply_constraints: list
        - Pull from "Supply Constraints"

    Data.capacity_volume: numpy.ndarray
        - Pull from "Capacity Volume"

    """
    # Data.product_list
    Data.product_list = pd.read_excel(
        Data.filepath, sheet_name='Product List')['PRODUCT'].values.tolist()

    # Data.factory_list
    Data.factory_list = pd.read_excel(
        Data.filepath, sheet_name='Factory List')['FACTORY'].values.tolist()

    # Data.factory_name/s (df temporary stores the work sheet)
    df = pd.read_excel(Data.filepath,
                       sheet_name='Factory Per Product',
                       index_col=0)

    try:
        Data.factory_names = {
            prod: [fac for fac in df.columns[df.loc[prod]]
                   if str(Data.year) in fac]
            for prod in Data.product_list
        }
        del df
    except:
        print("\033[1;31mFactory Per Product sheet is empty. Please fill in the necessary data\033[0;0m")
        raise EmptySheetError("Factory Per Product")
       
    # Data.inbound_cost_per_product
    df = pd.read_excel(Data.filepath,
                       sheet_name='Inbound Cost Per Product',
                       index_col=0)

    try:
        Data.inbound_cost_per_product = {
            prod: df.loc[prod][Data.factory_names[prod]].tolist()
            for prod in Data.product_list
        }

        del df
    except:
        print("\033[1;31mOne of the input sheet is empty. Please fill in the necessary data\033[0;0m")
        raise EmptySheetError("Inbound Cost Per Product")
  

    # Data.outbound_cost_per_product
    df = pd.read_excel(Data.filepath, sheet_name='Outbound Cost', index_col=0)

    try:
        Data.outbound_cost_per_product = {
            prod: df[df['Sales Product'] ==
                     prod][Data.factory_names[prod]].to_numpy().flatten('F')
            for prod in Data.product_list
        }
    except:
        print("\033[1;31mOutbound Cost Per Product sheet is empty. Please fill in the necessary data\033[0;0m")
        raise EmptySheetError("Outbound Cost Per Product")
  
        
    # Data.demand_volume
    df = pd.read_excel(Data.filepath, sheet_name='Sales Volume', index_col=0)

    try:
        Data.demand_volume = np.hstack([
            df[df['Sales Product'] == prod][df.columns[
                2 + Data.year - Data.timeframe[0]]].to_numpy().flatten('F')
            for prod in Data.product_list
        ])[:, np.newaxis]

        del df
    except:
        print("\033[1;31mOne of the input sheet is empty. Please fill in the necessary data\033[0;0m")
        raise EmptySheetError("Sales Volume")
        
    # Data.efficiency_per_product
    df = pd.read_excel(Data.filepath,
                       sheet_name='Efficiency Per Product',
                       index_col=0)

    try:
        Data.efficiency_per_product = {
            prod: df.loc[prod][Data.factory_names[prod]].tolist()
            for prod in Data.product_list
        }
        del df
    except:
        print("\033[1;31mOne of the input sheet is empty. Please fill in the necessary data\033[0;0m")
        raise EmptySheetError("Efficiency Per Product")
  

    # Data.capacity_constraints # Constraints has to start index from 1
    df = pd.read_excel(Data.filepath,
                       sheet_name='Capacity Constraints',
                       index_col='CONSTRAINT')

    df_prod = pd.DataFrame(
        columns=[prod for prod in df.columns
                 if str(Data.year) in prod]).columns

    try:
        Data.capacity_constraints = [
            df_prod[df[df_prod].iloc[cons]].to_list()
            for cons in range(df.shape[0])
        ]
        del df
    except:
        print("\033[1;31mCapacity Constraints sheet is empty. Please fill in the necessary data\033[0;0m")
        raise EmptySheetError("Capacity Constraints")
  

    # Data.supply_constraints # Constraints has to start index from 1
    df = pd.read_excel(Data.filepath,
                       sheet_name='Supply Constraints',
                       index_col='CONSTRAINT')

    df_prod = pd.DataFrame(
        columns=[prod for prod in df.columns
                 if str(Data.year) in prod]).columns

    try:
        Data.supply_constraints = [
            df_prod[df[df_prod].iloc[cons]].to_list()
            for cons in range(df.shape[0])
        ]
        del df, df_prod
    except:
        print("\033[1;31mSupply Constraints sheet is empty. Please fill in the necessary data\033[0;0m")
        raise EmptySheetError("Supply Constraints")

    # Data.capacity_volume
    try: 
        Data.capacity_volume = pd.read_excel(
            Data.filepath, sheet_name='Capacity Volume',
            index_col='CONSTRAINT')[[str(Data.year) + " - " + str(fac)
                                    for fac in Data.factory_list
                                     ]].to_numpy().flatten()

        Data.capacity_volume = Data.capacity_volume[~np.isnan(Data.capacity_volume
                                                              )][:, np.newaxis]
    except:
        print("\033[1;31mCapacity Volume sheet is empty. Please fill in the necessary data\033[0;0m")
        raise EmptySheetError("Capacity Volume")
  
    # Revert the factory_names to simple no year names
    Data.factory_names = {prod: [fac.strip(str(Data.year) + " - ")
                                 for fac in Data.factory_names[prod]]
                          for prod in Data.factory_names}

    # Revert capacity constraints
    Data.capacity_constraints = [
        [prod.strip(str(Data.year) + " - ") for prod in cons]
        for cons in Data.capacity_constraints]

    # Revert supply constraints
    Data.supply_constraints = [
        [prod.strip(str(Data.year) + " - ") for prod in cons]
        for cons in Data.supply_constraints]


def processed_inputs():
    """
    Data processed from Raw Inputs

    Outputs to data.py
    ------------------
    Data.factory_sizes: dict
        - Process from Data.factory_names

    Data.customer_sizes: dict
        - Process from ...

    Data.dimF: int
        - Process from Data.factory_sizes

    Data.dimC: int
        - Process from Data.customer_sizes

    Data.dimFC: int
        - Process from Data.factory_sizes x Data.customer_sizes

    """

    # Data.factory_sizes
    Data.factory_sizes = {
        prod: len(Data.factory_names[prod])
        for prod in Data.product_list
    }

    # Data.customer_sizes (Pending changes)
    # Might want to do Data.customer_list and Data.customer_names
    # as well, for the postprocessing

    Data.customer_sizes = {
        prod:
            len(Data.outbound_cost_per_product[prod]) // Data.factory_sizes[
                prod]
        for prod in Data.product_list
    }

    # Data.dimF
    Data.dimF = sum(Data.factory_sizes.values())

    # Data.dimC
    Data.dimC = sum(Data.customer_sizes.values())

    # Data.dimFC
    Data.dimFC = sum(
        np.array(list(Data.factory_sizes.values())) *
        np.array(list(Data.customer_sizes.values())))


def preprocess():
    """
    Call on the raw and processed inputs, then checks if the inputs.
    are logical through a series of assert statement.

    After doing this,
    if we get an error in an assert statement, we know the values is wrong,
    else we know that the input is not the correct format.

    """
    # Retrieve the inputs
    raw_inputs()
    processed_inputs()

    # Assert logicality of inputs
