/*
 * SPDX-License-Identifier: Apache-2.0
 */
// Deterministic JSON.stringify()
import {Context, Contract, Info, Returns, Transaction} from 'fabric-contract-api';
import stringify from 'json-stringify-deterministic';
import sortKeysRecursive from 'sort-keys-recursive';
import { PemetaanHutan } from './pemetaanHutan';
var moment = require('moment');
interface QueryPersetujuan {
  selector: {
    persetujuanId: string;
  };
}

interface QueryString {
  selector: {
    nim: string;
  };
}

interface QueryByMitra {
  selector: {
    mitraId: string;
  };
}
@Info({title: 'RegistrySmartContract', description: 'Smart contract for registry MBKM'})
export class PemetaanHutanSmartContract extends Contract {
    
    // CreateAsset issues a new asset to the world state with given details.
    @Transaction()
    public async CreateAsset(ctx: Context, idHutan: string, namaHutan: string, longitude: string, latitude: string, ): Promise<any> {
        const exists = await this.AssetExists(ctx, idHutan);
        if (exists) {
            throw new Error(`Aset dengan ID ${idHutan} tidak ditemukan.`);
        }

        const asset: PemetaanHutan = {
            idHutan: idHutan,
            namaHutan: namaHutan,
            longitude: longitude,
            latitude: latitude,
            created_at: moment().format(),
            updated_at: moment().format(),
        };

        // we insert data in alphabetic order using 'json-stringify-deterministic' and 'sort-keys-recursive'
        await ctx.stub.putState(idHutan, Buffer.from(stringify(sortKeysRecursive(asset))));
        const idTrx = ctx.stub.getTxID()
        return {"status":"success","idTrx":idTrx,"message":`Pemetaan Hutan Berhasil`}
    }

    // ReadAsset returns the asset stored in the world state with given id.
    @Transaction(false)
    public async ReadAsset(ctx: Context, idHutan: string): Promise<string> {
        const assetJSON = await ctx.stub.getState(idHutan); // get the asset from chaincode state
        if (!assetJSON || assetJSON.length === 0) {
            throw new Error(`The asset ${idHutan} does not exist`);
        }
        return assetJSON.toString();
    }


    // AssetExists returns true when asset with given ID exists in world state.
    @Transaction(false)
    @Returns('boolean')
    public async AssetExists(ctx: Context, idHutan: string): Promise<boolean> {
        const assetJSON = await ctx.stub.getState(idHutan);
        return assetJSON && assetJSON.length > 0;
    }

    // GetAllAssets returns all assets found in the world state.
    @Transaction(false)
    @Returns('string')
    public async GetAllAssets(ctx: Context): Promise<string> {
        const allResults = [];
        // range query with empty string for startKey and endKey does an open-ended query of all assets in the chaincode namespace.
        const iterator = await ctx.stub.getStateByRange('', '');
        let result = await iterator.next();
        while (!result.done) {
            const strValue = Buffer.from(result.value.value.toString()).toString('utf8');
            let record;
            try {
                record = JSON.parse(strValue);
            } catch (err) {
                console.log(err);
                record = strValue;
            }
            allResults.push(record);
            result = await iterator.next();
        }
        return JSON.stringify(allResults);
    }


    @Transaction()
    public async UpdatePemetaanHutan(ctx: Context, idHutan: string, namaHutan: string, longitude: string, latitude: string): Promise<any> {
        
      const exists = await this.AssetExists(ctx, idHutan);
        if (!exists) {
            throw new Error(`The asset ${idHutan} does not exist`);
        }

        // overwriting original asset with new asset
        const updatedAsset: PemetaanHutan = {
          idHutan: idHutan,
          namaHutan: namaHutan,
          longitude: longitude,
          latitude: latitude,
          created_at: moment().format(),
          updated_at: moment().format(),
      };

        // we insert data in alphabetic order using 'json-stringify-deterministic' and 'sort-keys-recursive'
        await ctx.stub.putState(idHutan, Buffer.from(stringify(sortKeysRecursive(updatedAsset))));
        const idTrx = ctx.stub.getTxID();
        return {"status":"success","idTrx":idTrx,"message":`Pemetaan Hutan Berhasil Di Perbarui`}
    }

        // DeleteAsset deletes an given asset from the world state.
        @Transaction()
        public async DeletePemetaanHutan(ctx: Context, idHutan: string): Promise<void> {
            const exists = await this.AssetExists(ctx, idHutan);
            if (!exists) {
                throw new Error(`Id Hutan Dengan ${idHutan} tidak ditemukan`);
            }
            return ctx.stub.deleteState(idHutan);
        }

}