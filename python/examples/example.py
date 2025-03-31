# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

import os
import h5py

from tsfile import ColumnSchema, TableSchema
from tsfile import Tablet
from tsfile import TsFileTableWriter, TsFileReader, TSDataType, TSEncoding, Compressor, ColumnCategory

import numpy as np
from datetime import datetime, timedelta
import time

## init a var to store the datas from each dataset
datas = {}

with h5py.File("export-1808881-B-301A-2024-01-01-ZPPP-ZGGG.hdf5", "r") as file:
    # get the group by name which is "recoreded parameters"
    group = file["Recorded Parameters"]
    # for each dataset in the group, print the name and datatype
    for name, dataset in group.items():
        if dataset.dtype["Value"] == np.float32:
            # store the whole dataset in the datas and the dataset type is compound which is time double, value float, flags int
            # convert the dataset to a numpy array
            datas[name] = dataset[:]

    group = file["Computed Parameters"]
    # for each dataset in the group, print the name and datatype
    for name, dataset in group.items():
        if dataset.dtype["Value"] == np.float32:
            # store the whole dataset in the datas and the dataset type is compound which is time double, value float, flags int
            # convert the dataset to a numpy array
            datas[name] = dataset[:]

print(len(datas))
# print(datas)

# starttime
start_time = time.time()

#  Write
table_data_dir = os.path.join(os.path.dirname(__file__), "table_data.tsfile")
if os.path.exists(table_data_dir):
    os.remove(table_data_dir)

column1 = ColumnSchema("name", TSDataType.STRING, ColumnCategory.TAG)
column2 = ColumnSchema("value", TSDataType.FLOAT, ColumnCategory.FIELD)
column3 = ColumnSchema("flags", TSDataType.BOOLEAN, ColumnCategory.FIELD)
table_schema = TableSchema("float_table", columns=[column1, column2, column3])

### Free resource automatically
with TsFileTableWriter(table_data_dir, table_schema) as writer:
    for name, data in datas.items():
        tablet_row_num = len(data)
        tablet = Tablet(
            ["name", "value", "flags"],
            [TSDataType.STRING, TSDataType.FLOAT, TSDataType.BOOLEAN],
            tablet_row_num)
        min_value, max_value = 0, 0
        # add data
        for i in range(tablet_row_num):
            tablet.add_value_by_name("name", i, name)
            tablet.add_timestamp(i, (int)(data["Time"][i]))
            tablet.add_value_by_name("value", i, float(data["Value"][i]))
            tablet.add_value_by_name("flags", i, (bool)(data["Flags"][i] == 1))

        writer.write_table(tablet)

##  Read
### Free resource automatically
with TsFileReader(table_data_dir) as reader:
    with reader.query_table("float_table", ["name", "value", "flags"]) as result:
        while result.next():
            print(result.get_value_by_name("value"))